import Foundation
import MediaPlayer
import UIKit
import Combine

@MainActor
final class NowPlayingManager: ObservableObject {
    static let shared = NowPlayingManager()

    @Published var info: NowPlayingInfoModel = .empty
    @Published var artworkImage: UIImage?

    private let player = MPMusicPlayerController.systemMusicPlayer
    private var observers: [NSObjectProtocol] = []

    private init() {
        startObserving()
        refresh()
    }

    deinit {
        let observers = observers
        let player = player
        Task { @MainActor in
            player.endGeneratingPlaybackNotifications()
            observers.forEach { NotificationCenter.default.removeObserver($0) }
        }
    }

    private func startObserving() {
        player.beginGeneratingPlaybackNotifications()

        let center = NotificationCenter.default

        observers.append(center.addObserver(
            forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: player,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        })

        observers.append(center.addObserver(
            forName: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: player,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        })

        observers.append(center.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        })

        observers.append(center.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        })
    }

    func refresh() {
        guard let item = player.nowPlayingItem else {
            info = .empty
            artworkImage = nil
            return
        }

        let title = item.title ?? ""
        let artist = item.artist ?? ""

        info = NowPlayingInfoModel(
            rawTitle: title,
            normalizedTitle: Self.normalize(title),
            rawArtist: artist,
            normalizedArtist: Self.normalize(artist),
            artworkURL: nil,
            updatedAt: Date()
        )

        if let artwork = item.artwork {
            artworkImage = artwork.image(at: CGSize(width: 200, height: 200))
        } else {
            artworkImage = nil
        }
    }

    // MARK: - Normalization (minimal; will be replaced by StringNormalizer)

    private static func normalize(_ input: String) -> String {
        input
            .folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
