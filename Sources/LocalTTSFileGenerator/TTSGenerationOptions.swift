import Foundation

public struct TTSGenerationOptions: Sendable {
    public let fileNamePrefix: String
    public let rate: Float
    public let pitchMultiplier: Float
    public let volume: Float

    public init(
        fileNamePrefix: String = "tts",
        rate: Float = 0.5,
        pitchMultiplier: Float = 1.0,
        volume: Float = 1.0
    ) {
        self.fileNamePrefix = fileNamePrefix
        self.rate = rate
        self.pitchMultiplier = pitchMultiplier
        self.volume = volume
    }

    var normalizedFileNamePrefix: String {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let sanitizedScalars = fileNamePrefix.unicodeScalars.map { scalar in
            allowedCharacters.contains(scalar) ? Character(scalar) : "_"
        }
        let sanitized = String(sanitizedScalars)
            .trimmingCharacters(in: CharacterSet(charactersIn: "_-"))

        return sanitized.isEmpty ? "tts" : sanitized
    }

    var normalizedRate: Float {
        min(max(rate, 0.0), 1.0)
    }

    var normalizedPitchMultiplier: Float {
        min(max(pitchMultiplier, 0.5), 2.0)
    }

    var normalizedVolume: Float {
        min(max(volume, 0.0), 1.0)
    }
}
