@preconcurrency import AVFoundation
import Foundation

public struct TTSVoiceSelector: Sendable {
    public init() {}

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
