@preconcurrency import AVFoundation
import Foundation

public struct TTSVoiceInfo: Sendable, Equatable {
    public let identifier: String
    public let name: String
    public let languageCode: String
    public let quality: String

    public init(identifier: String, name: String, languageCode: String, quality: String) {
        self.identifier = identifier
        self.name = name
        self.languageCode = languageCode
        self.quality = quality
    }

    init(voice: AVSpeechSynthesisVoice) {
        self.init(
            identifier: voice.identifier,
            name: voice.name,
            languageCode: voice.language,
            quality: voice.quality.description
        )
    }
}

extension AVSpeechSynthesisVoiceQuality {
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
