import AVFoundation

@MainActor
final class PlayerViewModel: NSObject {
    private let tracks: [Track]
    private var audioPlayer: AVAudioPlayer?

    private(set) var currentIndex = 0
    private(set) var isPlaying = false

    var onChange: (() -> Void)?
    var onError: ((String) -> Void)?

    var currentTrack: Track {
        tracks[currentIndex]
    }

    init(tracks: [Track]) {
        self.tracks = tracks
        super.init()
    }

    func start() {
        configureAudioSession()
        loadCurrentTrack()
        onChange?()
    }

    func togglePlayPause() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else if let audioPlayer {
            isPlaying = audioPlayer.play()
        } else {
            report("Cannot play \"\(currentTrack.title)\": audio file is not loaded")
        }
        onChange?()
    }

    func next() {
        moveTrack(by: 1)
    }

    func previous() {
        moveTrack(by: -1)
    }

    private func moveTrack(by offset: Int) {
        guard !tracks.isEmpty else { return }
        let wasPlaying = isPlaying
        currentIndex = (currentIndex + offset + tracks.count) % tracks.count
        loadCurrentTrack()
        isPlaying = wasPlaying ? (audioPlayer?.play() ?? false) : false
        onChange?()
    }

    private func loadCurrentTrack() {
        audioPlayer?.stop()
        audioPlayer = nil

        let track = currentTrack
        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: track.fileExtension) else {
            report("File \(track.fileName).\(track.fileExtension) was not found in the app bundle")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            audioPlayer = player
        } catch {
            report("Cannot open \(track.fileName).\(track.fileExtension): \(error.localizedDescription)")
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }
    }

    private func report(_ message: String) {
        print("PlayerViewModel: \(message)")
        onError?(message)
    }
}

extension PlayerViewModel: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.next()
        }
    }
}
