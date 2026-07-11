import AVFoundation
import Foundation

public enum TTSGenerationEvent: Sendable {
    case started
    case voiceSelected(TTSVoiceInfo)
    case firstBufferReceived
    case bufferWritten(frameLength: AVAudioFramePosition)
    case finished(TTSGenerationResult)
}
