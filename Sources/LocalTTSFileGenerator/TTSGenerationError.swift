import Foundation

public enum TTSGenerationError: LocalizedError, Sendable {
    case emptyText
    case voiceUnavailable(languageCode: String)
    case missingPCMBuffer
    case bufferFormatChanged
    case fileCreationFailed
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .emptyText:
            "A felolvasandó szöveg nem lehet üres."
        case .voiceUnavailable(let languageCode):
            "Nincs telepített, pontosan \(languageCode) nyelvű beszédhang."
        case .missingPCMBuffer:
            "A beszédszintetizáló nem PCM hangbuffert adott vissza."
        case .bufferFormatChanged:
            "A beszédszintetizáló bufferformátuma írás közben megváltozott."
        case .fileCreationFailed:
            "A hangfájl létrehozása nem sikerült."
        case .cancelled:
            "A hangfájl generálása megszakadt."
        }
    }
}
