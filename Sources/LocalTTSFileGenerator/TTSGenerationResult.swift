import Foundation

public struct TTSGenerationResult: Sendable {
    public let fileURL: URL
    public let fileName: String
    public let languageCode: String
    public let fileSize: Int64
    public let createdAt: Date
    public let containerFormat: String
    public let audioFormat: String
    public let selectedVoiceIdentifier: String
    public let selectedVoiceName: String
    public let selectedVoiceQuality: String
    public let metadata: TTSAudioFileMetadata?

    public init(
        fileURL: URL,
        fileName: String,
        languageCode: String,
        fileSize: Int64,
        createdAt: Date,
        containerFormat: String,
        audioFormat: String,
        selectedVoiceIdentifier: String,
        selectedVoiceName: String,
        selectedVoiceQuality: String,
        metadata: TTSAudioFileMetadata? = nil
    ) {
        self.fileURL = fileURL
        self.fileName = fileName
        self.languageCode = languageCode
        self.fileSize = fileSize
        self.createdAt = createdAt
        self.containerFormat = containerFormat
        self.audioFormat = audioFormat
        self.selectedVoiceIdentifier = selectedVoiceIdentifier
        self.selectedVoiceName = selectedVoiceName
        self.selectedVoiceQuality = selectedVoiceQuality
        self.metadata = metadata
    }
}
