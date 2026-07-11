import Foundation

public protocol TTSFileGenerating: Sendable {
    func generate(request: TTSGenerationRequest) async throws -> TTSGenerationResult
    func startGeneration(request: TTSGenerationRequest) -> any TTSGenerationSessioning
    func availableVoices(languageCode: String) -> [TTSVoiceInfo]
    func isLanguageAvailable(_ languageCode: String) -> Bool
}
