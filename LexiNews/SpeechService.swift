import AVFoundation
import Combine

@MainActor
final class SpeechService: NSObject, ObservableObject {

    @Published private(set) var isPlaying = false
    @Published private(set) var isPaused  = false

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
    }

    func play(text: String, language: String = "en-US") {
        if isPaused {
            synthesizer.continueSpeaking()
            isPlaying = true; isPaused = false
            return
        }
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate  = 0.48
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
        isPlaying = true
    }

    func pause() {
        guard isPlaying else { return }
        synthesizer.pauseSpeaking(at: .word)
        isPlaying = false; isPaused = true
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false; isPaused = false
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isPlaying = false; self.isPaused = false }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isPlaying = false; self.isPaused = false }
    }
}
