import AVFoundation
import Foundation

/// One shared player for ayah and word clips.
final class AyahAudio: ObservableObject {
    static let shared = AyahAudio()

    @Published var playingKey: String?

    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?

    func toggle(_ urlString: String, key: String) {
        if playingKey == key {
            stop()
            return
        }
        guard let url = URL(string: urlString), !urlString.isEmpty else { return }

        stop()
        let player = AVPlayer(url: url)
        self.player = player
        playingKey = key
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.playingKey = nil
        }
        player.play()
    }

    func stop() {
        player?.pause()
        player = nil
        playingKey = nil
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }

    func isPlaying(_ key: String) -> Bool { playingKey == key }
}
