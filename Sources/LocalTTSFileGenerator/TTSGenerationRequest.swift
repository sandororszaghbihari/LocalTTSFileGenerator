import Foundation

public typealias TTSGenerationEventHandler = @Sendable (TTSGenerationEvent) -> Void

public struct TTSGenerationRequest: Sendable {
    public let text: String
    public let languageCode: String
    public let outputDirectory: URL
    public let fileName: String?
    public let options: TTSGenerationOptions
    public let eventHandler: TTSGenerationEventHandler?

    public init(
        text: String,
        languageCode: String,
        outputDirectory: URL,
        fileName: String? = nil,
        options: TTSGenerationOptions = TTSGenerationOptions(),
        eventHandler: TTSGenerationEventHandler? = nil
    ) {
        self.text = text
        self.languageCode = languageCode
        self.outputDirectory = outputDirectory
        self.fileName = fileName
        self.options = options
        self.eventHandler = eventHandler
    }
}
