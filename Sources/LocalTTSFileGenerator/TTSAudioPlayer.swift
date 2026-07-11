@preconcurrency import AVFoundation
import Foundation

public enum TTSAudioPlaybackError: LocalizedError, Sendable {
    case playbackFailed

    public var errorDescription: String? {
        switch self {
        case .playbackFailed:
            "The audio file could not be played."
        }
    }
}

@MainActor
public protocol TTSAudioPlayerDelegate: AnyObject {
    func ttsAudioPlayerDidFinishPlaying(_ player: TTSAudioPlayer)
}

@MainActor
public final class TTSAudioPlayer: NSObject, AVAudioPlayerDelegate {
    public weak var delegate: TTSAudioPlayerDelegate?

    private var player: AVAudioPlayer?

    public var isPlaying: Bool {
        player?.isPlaying == true
    }

    public override init() {
        super.init()
    }

    public func play(result: TTSGenerationResult) throws {
        try play(url: result.fileURL)
    }

    public func play(url: URL) throws {
        stop()
        try configureAudioSession()

        let player = try AVAudioPlayer(contentsOf: url)
        player.delegate = self
        player.prepareToPlay()

        guard player.play() else {
            throw TTSAudioPlaybackError.playbackFailed
        }

        self.player = player
    }

    public func pause() {
        player?.pause()
    }

    public func resume() throws {
        guard let player else {
            throw TTSAudioPlaybackError.playbackFailed
        }

        try configureAudioSession()

        guard player.play() else {
            throw TTSAudioPlaybackError.playbackFailed
        }
    }

    public func stop() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        delegate?.ttsAudioPlayerDidFinishPlaying(self)
    }

    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .spokenAudio, options: [])
        try audioSession.setActive(true)
    }
}
