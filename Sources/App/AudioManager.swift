import AVFoundation

final class AudioManager {
    static let shared = AudioManager()

    private var player: AVAudioPlayer?
    private let targetVolume: Float = 0.28

    func start() {
        guard player == nil else { return }

        guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else { return }

        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(
                .playback, mode: .default, options: []
            )
            try AVAudioSession.sharedInstance().setActive(true)
            #endif

            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = -1
            p.volume = targetVolume
            p.prepareToPlay()
            p.play()
            player = p
        } catch {
            // Audio unavailable — app continues silently
        }
    }
}
