@preconcurrency import AVFoundation
import Foundation

public struct TTSVoiceSelector: Sendable {
    public init() {}

    public func availableVoices(languageCode: String) -> [TTSVoiceInfo] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language == languageCode }
            .sorted { lhs, rhs in
                lhs.quality.sortPriority > rhs.quality.sortPriority
            }
            .map(TTSVoiceInfo.init)
    }

    public func isLanguageAvailable(_ languageCode: String) -> Bool {
        !availableVoices(languageCode: languageCode).isEmpty
    }

    public func selectVoice(languageCode: String) -> AVSpeechSynthesisVoice? {
        let matchingVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language == languageCode }

        let preferredQualities: [AVSpeechSynthesisVoiceQuality] = [.premium, .enhanced, .default]
        for quality in preferredQualities {
            if let voice = matchingVoices.first(where: { $0.quality == quality }) {
                return voice
            }
        }

        return nil
    }
}

private extension AVSpeechSynthesisVoiceQuality {
    var sortPriority: Int {
        switch self {
        case .premium:
            3
        case .enhanced:
            2
        case .default:
            1
        @unknown default:
            0
        }
    }
}
