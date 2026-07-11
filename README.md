# LocalTTSFileGenerator

`LocalTTSFileGenerator` is a small Swift Package for generating local text-to-speech audio files on iOS using native Apple APIs.

It uses:

- Swift
- AVFoundation
- `AVSpeechSynthesizer.write(_:toBufferCallback:)`
- CAF container
- Linear PCM audio
- Swift concurrency

The package does not include UI, file indexing, or persistence logic. It generates an audio file and can optionally play it back with `AVAudioPlayer`.

## Requirements

- iOS 17.0+
- Swift Package Manager
- A real iPhone is recommended for final validation of installed voices and speech synthesis behavior.

## Installation

In Xcode:

1. Select `File > Add Package Dependencies...`
2. Enter the repository URL:

   ```text
   https://github.com/sandororszaghbihari/LocalTTSFileGenerator.git
   ```

3. Add the `LocalTTSFileGenerator` product to your app target.

## Usage

```swift
import LocalTTSFileGenerator

let generator = TTSFileGenerator()

let result = try await generator.generate(
    text: "Szeretnek Sziciliaban hazat venni.",
    languageCode: "it-IT",
    outputDirectory: outputDirectory
)

print(result.fileURL)
```

## Voice Availability

```swift
let voices = generator.availableVoices(languageCode: "it-IT")
let canGenerateItalian = generator.isLanguageAvailable("it-IT")
```

The voice selector tries premium, enhanced, then default quality voices for the exact requested language. It does not silently fall back to another language.

## Generation Options

```swift
let options = TTSGenerationOptions(
    fileNamePrefix: "lesson_intro",
    rate: 0.48,
    pitchMultiplier: 1.0,
    volume: 1.0
)

let result = try await generator.generate(
    text: "Buongiorno.",
    languageCode: "it-IT",
    outputDirectory: outputDirectory,
    options: options
)
```

## Generation Events

```swift
let result = try await generator.generate(
    text: "Buongiorno.",
    languageCode: "it-IT",
    outputDirectory: outputDirectory,
    options: TTSGenerationOptions()
) { event in
    switch event {
    case .started:
        print("Started")
    case .voiceSelected(let voice):
        print("Voice:", voice.name)
    case .firstBufferReceived:
        print("First buffer")
    case .bufferWritten(let frameLength):
        print("Wrote frames:", frameLength)
    case .finished(let result):
        print("Finished:", result.fileURL)
    }
}
```

## Cancellation

```swift
let session = generator.startGeneration(
    text: longText,
    languageCode: "hu-HU",
    outputDirectory: outputDirectory
)

session.cancel()
```

If you want the result:

```swift
let result = try await session.result
```

## Metadata

`TTSGenerationResult` includes optional audio metadata:

```swift
if let metadata = result.metadata {
    print(metadata.duration)
    print(metadata.sampleRate)
    print(metadata.channelCount)
}
```

You can also read metadata from an existing file:

```swift
let metadata = try TTSAudioMetadataReader.metadata(for: result.fileURL)
```

## Playback

```swift
let player = TTSAudioPlayer()
try player.play(result: result)
```

You can also play any generated file URL directly:

```swift
try player.play(url: result.fileURL)
```

## Output

Generated files use:

- Container: CAF
- Audio format: Linear PCM
- File extension: `.caf`

The generated file is directly playable with `AVAudioPlayer`.

## Supported Languages

The package accepts any BCP-47 language code supported by the installed iOS voices, for example:

- `hu-HU`
- `en-US`
- `es-ES`
- `it-IT`
