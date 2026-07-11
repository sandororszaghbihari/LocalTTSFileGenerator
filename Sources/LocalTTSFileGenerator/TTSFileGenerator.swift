@preconcurrency import AVFoundation
import Foundation

public nonisolated final class TTSFileGenerator: TTSFileGenerating {
    private let fileManager: FileManager
    private let voiceSelector: any TTSVoiceSelecting
    private let fileNameProvider: any TTSFileNameProviding
    private let metadataReader: any TTSAudioMetadataReading

    public init(
        fileManager: FileManager = .default,
        voiceSelector: any TTSVoiceSelecting = TTSVoiceSelector(),
        fileNameProvider: any TTSFileNameProviding = TTSCAFFileNameProvider(),
        metadataReader: any TTSAudioMetadataReading = TTSAudioMetadataReader()
    ) {
        self.fileManager = fileManager
        self.voiceSelector = voiceSelector
        self.fileNameProvider = fileNameProvider
        self.metadataReader = metadataReader
    }

    public func generate(request: TTSGenerationRequest) async throws -> TTSGenerationResult {
        let createdAt = Date()
        let trimmedText = request.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            throw TTSGenerationError.emptyText
        }

        let eventHandler = request.eventHandler
        eventHandler?(.started)

        guard let voice = voiceSelector.selectVoice(languageCode: request.languageCode) else {
            throw TTSGenerationError.voiceUnavailable(languageCode: request.languageCode)
        }

        let voiceInfo = TTSVoiceInfo(voice: voice)
        eventHandler?(.voiceSelected(voiceInfo))

        let fileName = request.fileName ?? fileNameProvider.fileName(
            languageCode: request.languageCode,
            createdAt: createdAt,
            options: request.options
        )
        let destinationURL = request.outputDirectory.appendingPathComponent(fileName, isDirectory: false)

        try fileManager.createDirectory(
            at: destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        do {
            try await SpeechFileWriteSession(
                text: trimmedText,
                voice: voice,
                destinationURL: destinationURL,
                options: request.options,
                eventHandler: eventHandler
            ).start()

            let fileSize = try fileSize(at: destinationURL)
            let metadata = try? metadataReader.metadata(for: destinationURL)

            let result = TTSGenerationResult(
                fileURL: destinationURL,
                fileName: destinationURL.lastPathComponent,
                languageCode: request.languageCode,
                fileSize: fileSize,
                createdAt: createdAt,
                containerFormat: "CAF",
                audioFormat: "Linear PCM",
                selectedVoiceIdentifier: voiceInfo.identifier,
                selectedVoiceName: voiceInfo.name,
                selectedVoiceQuality: voiceInfo.quality,
                metadata: metadata
            )

            eventHandler?(.finished(result))
            return result
        } catch {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try? fileManager.removeItem(at: destinationURL)
            }
            throw error
        }
    }

    public func startGeneration(request: TTSGenerationRequest) -> any TTSGenerationSessioning {
        TTSGenerationSession(
            task: Task {
                try await generate(request: request)
            }
        )
    }

    public func availableVoices(languageCode: String) -> [TTSVoiceInfo] {
        voiceSelector.availableVoices(languageCode: languageCode)
    }

    public func isLanguageAvailable(_ languageCode: String) -> Bool {
        voiceSelector.isLanguageAvailable(languageCode)
    }

    private func fileSize(at url: URL) throws -> Int64 {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
}
