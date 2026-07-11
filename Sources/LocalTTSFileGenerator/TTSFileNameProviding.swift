import Foundation

public protocol TTSFileNameProviding: Sendable {
    func fileName(languageCode: String, createdAt: Date, options: TTSGenerationOptions) -> String
}

public struct TTSCAFFileNameProvider: TTSFileNameProviding {
    public init() {}

    public func fileName(languageCode: String, createdAt: Date, options: TTSGenerationOptions) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"

        let safeLanguageCode = languageCode.replacingOccurrences(of: "/", with: "-")
        return "\(options.normalizedFileNamePrefix)_\(safeLanguageCode)_\(formatter.string(from: createdAt))_\(UUID().uuidString).caf"
    }
}
