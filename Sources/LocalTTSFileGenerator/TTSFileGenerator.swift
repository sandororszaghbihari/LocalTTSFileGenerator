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
        let createdAt = Date()
        let fileName = makeUniqueCAFFileName(
            languageCode: languageCode,
            createdAt: createdAt,
            id: UUID()
        )
        let destinationURL = outputDirectory.appendingPathComponent(fileName, isDirectory: false)

        return try await generate(
            text: text,
            languageCode: languageCode,
            destinationURL: destinationURL,
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
            createdAt: Date()
        )
    }

    private func generate(
        text: String,
        languageCode: String,
        destinationURL: URL,
        createdAt: Date
    ) async throws -> TTSGenerationResult {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            throw TTSGenerationError.emptyText
        }

        guard let voice = voiceSelector.selectVoice(languageCode: languageCode) else {
            throw TTSGenerationError.voiceUnavailable(languageCode: languageCode)
        }

        try fileManager.createDirectory(
            at: destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        do {
            try await SpeechFileWriteSession(
                text: trimmedText,
                voice: voice,
                destinationURL: destinationURL
            ).start()

            let fileSize = try fileSize(at: destinationURL)

            return TTSGenerationResult(
                fileURL: destinationURL,
                fileName: destinationURL.lastPathComponent,
                languageCode: languageCode,
                fileSize: fileSize,
                createdAt: createdAt,
                containerFormat: "CAF",
                audioFormat: "Linear PCM",
                selectedVoiceIdentifier: voice.identifier,
                selectedVoiceName: voice.name,
                selectedVoiceQuality: voice.quality.description
            )
        } catch {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try? fileManager.removeItem(at: destinationURL)
            }
            throw error
        }
    }

    private func makeUniqueCAFFileName(languageCode: String, createdAt: Date, id: UUID) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"

        let safeLanguageCode = languageCode.replacingOccurrences(of: "/", with: "-")
        return "tts_\(safeLanguageCode)_\(formatter.string(from: createdAt))_\(id.uuidString).caf"
    }

    private func fileSize(at url: URL) throws -> Int64 {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
}

private extension AVSpeechSynthesisVoiceQuality {
    var description: String {
        switch self {
        case .default:
            "default"
        case .enhanced:
            "enhanced"
        case .premium:
            "premium"
        @unknown default:
            "unknown"
        }
    }
}
