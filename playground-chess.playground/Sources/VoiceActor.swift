import Foundation
import AVFoundation

public class VoiceActor: NSObject, AVSpeechSynthesizerDelegate {
    
    let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    let voice: AVSpeechSynthesisVoice = AVSpeechSynthesisVoice(language: "en-UK")!
    
    public override init() {
        super.init()
        self.synthesizer.delegate = self
    }
    
    public func say(words: String) {
        let utterance = AVSpeechUtterance(string: words)
        utterance.voice = self.voice
        
        let lo = AVSpeechUtteranceMinimumSpeechRate
        let hi = AVSpeechUtteranceMaximumSpeechRate
        
        utterance.rate = lo + 0.38*(hi-lo)
        
        self.synthesizer.speak(utterance)
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
    }
    
}
