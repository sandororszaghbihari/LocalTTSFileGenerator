import Foundation

public protocol TTSFileGenerating: Sendable {
    func generate(
        text: String,
        languageCode: String,
        outputDirectory: URL
    ) async throws -> TTSGenerationResult

    func generate(
        text: String,
        languageCode: String,
        destinationURL: URL
    ) async throws -> TTSGenerationResult
}
