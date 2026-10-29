import UIKit

final class PlayerViewController: UIViewController {
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var artistLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!

    private let viewModel = PlayerViewModel(tracks: TrackLibrary.tracks)

    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
        viewModel.start()
    }

    @IBAction private func previousTapped(_ sender: UIButton) {
        viewModel.previous()
    }

    @IBAction private func playPauseTapped(_ sender: UIButton) {
        viewModel.togglePlayPause()
    }

    @IBAction private func nextTapped(_ sender: UIButton) {
        viewModel.next()
    }

    private func applyStyle() {
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .black
        view.tintColor = .white

        coverImageView.layer.cornerRadius = 10
        coverImageView.layer.cornerCurve = .continuous

        titleLabel.textColor = .white
        titleLabel.textAlignment = .natural
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)

        artistLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        artistLabel.textAlignment = .natural
        artistLabel.font = .systemFont(ofSize: 20, weight: .regular)
    }

    private func render() {
        let track = viewModel.currentTrack
        let cover = UIImage(named: track.coverImageName)

        coverImageView.image = cover
        titleLabel.text = track.title
        artistLabel.text = track.artist

        let symbolName = viewModel.isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: symbolName), for: .normal)

        let background = cover?.averageColor?.darkened(maxBrightness: 0.45) ?? .black
        let coverScale: CGFloat = viewModel.isPlaying ? 1 : 0.86

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.view.backgroundColor = background
            self.coverImageView.transform = CGAffineTransform(scaleX: coverScale, y: coverScale)
        }
    }

    private func showError(_ message: String) {
        guard view.window != nil, presentedViewController == nil else { return }
        let alert = UIAlertController(title: "Playback error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
