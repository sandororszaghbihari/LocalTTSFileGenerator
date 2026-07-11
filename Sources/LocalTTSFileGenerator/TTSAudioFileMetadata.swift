@preconcurrency import AVFoundation
import Foundation

public struct TTSAudioFileMetadata: Sendable, Equatable {
    public let duration: TimeInterval
    public let sampleRate: Double
    public let channelCount: UInt32
    public let frameCount: AVAudioFramePosition
    public let containerFormat: String
    public let audioFormat: String

    public init(
        duration: TimeInterval,
        sampleRate: Double,
        channelCount: UInt32,
        frameCount: AVAudioFramePosition,
        containerFormat: String,
        audioFormat: String
    ) {
        self.duration = duration
        self.sampleRate = sampleRate
        self.channelCount = channelCount
        self.frameCount = frameCount
        self.containerFormat = containerFormat
        self.audioFormat = audioFormat
    }
}

public enum TTSAudioMetadataReader {
    public static func metadata(for fileURL: URL) throws -> TTSAudioFileMetadata {
        let audioFile = try AVAudioFile(forReading: fileURL)
        let sampleRate = audioFile.fileFormat.sampleRate
        let duration = sampleRate > 0 ? TimeInterval(audioFile.length) / sampleRate : 0

        return TTSAudioFileMetadata(
            duration: duration,
            sampleRate: sampleRate,
            channelCount: audioFile.fileFormat.channelCount,
            frameCount: audioFile.length,
            containerFormat: "CAF",
            audioFormat: "Linear PCM"
        )
    }
}
