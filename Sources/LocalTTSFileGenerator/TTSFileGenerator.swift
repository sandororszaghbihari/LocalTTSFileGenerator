@preconcurrency import AVFoundation
import Foundation

public nonisolated final class TTSFileGenerator: TTSFileGenerating {
    private let fileManager: FileManager
    private let voiceSelector: TTSVoiceSelector

    public init(
        fileManager: FileManager = .default,
        voiceSelector: TTSVoiceSelector = TTSVoiceSelector()
    ) {
        self.fileManager = fileManager
        self.voiceSelector = voiceSelector
    }

    public func generate(
        text: String,
        languageCode: String,
        outputDirectory: URL
    ) async throws -> TTSGenerationResult {
        try await generate(
            text: text,
            languageCode: languageCode,
            outputDirectory: outputDirectory,
            options: TTSGenerationOptions(),
            eventHandler: nil
        )
    }

    public func generate(
        text: String,
        languageCode: String,
        outputDirectory: URL,
        options: TTSGenerationOptions,
        eventHandler: (@Sendable (TTSGenerationEvent) -> Void)? = nil
    ) async throws -> TTSGenerationResult {
        let createdAt = Date()
        let fileName = makeUniqueCAFFileName(
            languageCode: languageCode,
            createdAt: createdAt,
            id: UUID(),
            options: options
        )
        let destinationURL = outputDirectory.appendingPathComponent(fileName, isDirectory: false)

        return try await generate(
            text: text,
            languageCode: languageCode,
            destinationURL: destinationURL,
            options: options,
            eventHandler: eventHandler,
            createdAt: createdAt
        )
    }

    public func generate(
        text: String,
        languageCode: String,
        destinationURL: URL
    ) async throws -> TTSGenerationResult {
        try await generate(
            text: text,
            languageCode: languageCode,
            destinationURL: destinationURL,
            options: TTSGenerationOptions(),
            eventHandler: nil
        )
    }

    public func generate(
        text: String,
        languageCode: String,
        destinationURL: URL,
        options: TTSGenerationOptions,
        eventHandler: (@Sendable (TTSGenerationEvent) -> Void)? = nil
    ) async throws -> TTSGenerationResult {
        try await generate(
            text: text,
            languageCode: languageCode,
            destinationURL: destinationURL,
            options: options,
            eventHandler: eventHandler,
            createdAt: Date()
        )
    }

    public func startGeneration(
        text: String,
        languageCode: String,
        outputDirectory: URL,
        options: TTSGenerationOptions = TTSGenerationOptions(),
        eventHandler: (@Sendable (TTSGenerationEvent) -> Void)? = nil
    ) -> TTSGenerationSession {
        TTSGenerationSession(
            task: Task {
                try await generate(
                    text: text,
                    languageCode: languageCode,
                    outputDirectory: outputDirectory,
                    options: options,
                    eventHandler: eventHandler
                )
            }
        )
    }

    public func availableVoices(languageCode: String) -> [TTSVoiceInfo] {
        voiceSelector.availableVoices(languageCode: languageCode)
    }

    public func isLanguageAvailable(_ languageCode: String) -> Bool {
        voiceSelector.isLanguageAvailable(languageCode)
    }

    private func generate(
        text: String,
        languageCode: String,
        destinationURL: URL,
        options: TTSGenerationOptions,
        eventHandler: (@Sendable (TTSGenerationEvent) -> Void)?,
        createdAt: Date
    ) async throws -> TTSGenerationResult {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            throw TTSGenerationError.emptyText
        }

        eventHandler?(.started)

        guard let voice = voiceSelector.selectVoice(languageCode: languageCode) else {
            throw TTSGenerationError.voiceUnavailable(languageCode: languageCode)
        }

        let voiceInfo = TTSVoiceInfo(voice: voice)
        eventHandler?(.voiceSelected(voiceInfo))

        try fileManager.createDirectory(
            at: destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        do {
            try await SpeechFileWriteSession(
                text: trimmedText,
                voice: voice,
                destinationURL: destinationURL,
                options: options,
                eventHandler: eventHandler
            ).start()

            let fileSize = try fileSize(at: destinationURL)
            let metadata = try? TTSAudioMetadataReader.metadata(for: destinationURL)

            let result = TTSGenerationResult(
                fileURL: destinationURL,
                fileName: destinationURL.lastPathComponent,
                languageCode: languageCode,
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

    private func makeUniqueCAFFileName(
        languageCode: String,
        createdAt: Date,
        id: UUID,
        options: TTSGenerationOptions
    ) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"

        let safeLanguageCode = languageCode.replacingOccurrences(of: "/", with: "-")
        return "\(options.normalizedFileNamePrefix)_\(safeLanguageCode)_\(formatter.string(from: createdAt))_\(id.uuidString).caf"
    }

    private func fileSize(at url: URL) throws -> Int64 {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
}
