import Foundation

public struct TTSAudioPlaybackRequest: Sendable {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public init(result: TTSGenerationResult) {
        self.fileURL = result.fileURL
    }
}
