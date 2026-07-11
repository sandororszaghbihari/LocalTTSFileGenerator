import Foundation

public final class TTSGenerationSession: @unchecked Sendable {
    private let task: Task<TTSGenerationResult, Error>

    init(task: Task<TTSGenerationResult, Error>) {
        self.task = task
    }

    public var result: TTSGenerationResult {
        get async throws {
            try await task.value
        }
    }

    public func cancel() {
        task.cancel()
    }
}
