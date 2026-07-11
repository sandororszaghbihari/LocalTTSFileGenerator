@preconcurrency import AVFoundation
import Foundation

nonisolated final class SpeechFileWriteSession: NSObject {
    private let utterance: AVSpeechUtterance
    private let destinationURL: URL
    private let synthesizer = AVSpeechSynthesizer()
    private let lock = NSLock()

    private var audioFile: AVAudioFile?
    private var expectedFormat: AVAudioFormat?
    private var continuation: CheckedContinuation<Void, Error>?
    private var didComplete = false

    init(text: String, voice: AVSpeechSynthesisVoice, destinationURL: URL) {
        self.utterance = AVSpeechUtterance(string: text)
        self.destinationURL = destinationURL
        super.init()
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
    }

    func start() async throws {
        try Task.checkCancellation()

        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                lock.lock()
                self.continuation = continuation
                lock.unlock()

                synthesizer.write(utterance) { [self] buffer in
                    handle(buffer: buffer)
                }
            }
        } onCancel: {
            cancel()
        }
    }

    private func cancel() {
        lock.lock()
        defer { lock.unlock() }

        guard !didComplete else {
            return
        }

        synthesizer.stopSpeaking(at: .immediate)
        complete(with: .failure(TTSGenerationError.cancelled))
    }

    private func handle(buffer: AVAudioBuffer) {
        lock.lock()
        defer { lock.unlock() }

        guard !didComplete else {
            return
        }

        guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
            complete(with: .failure(TTSGenerationError.missingPCMBuffer))
            return
        }

        guard pcmBuffer.frameLength > 0 else {
            complete(with: .success(()))
            return
        }

        do {
            if audioFile == nil {
                expectedFormat = pcmBuffer.format
                audioFile = try AVAudioFile(
                    forWriting: destinationURL,
                    settings: pcmBuffer.format.settings,
                    commonFormat: pcmBuffer.format.commonFormat,
                    interleaved: pcmBuffer.format.isInterleaved
                )
            }

            guard formatsMatch(pcmBuffer.format, expectedFormat) else {
                complete(with: .failure(TTSGenerationError.bufferFormatChanged))
                return
            }

            guard let audioFile else {
                complete(with: .failure(TTSGenerationError.fileCreationFailed))
                return
            }

            try audioFile.write(from: pcmBuffer)
        } catch {
            complete(with: .failure(error))
        }
    }

    private func formatsMatch(_ lhs: AVAudioFormat, _ rhs: AVAudioFormat?) -> Bool {
        guard let rhs else {
            return false
        }

        return lhs.commonFormat == rhs.commonFormat
            && lhs.channelCount == rhs.channelCount
            && lhs.sampleRate == rhs.sampleRate
            && lhs.isInterleaved == rhs.isInterleaved
    }

    private func complete(with result: Result<Void, Error>) {
        didComplete = true
        audioFile = nil
        expectedFormat = nil

        guard let continuation else {
            return
        }

        self.continuation = nil

        switch result {
        case .success:
            continuation.resume()
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}
