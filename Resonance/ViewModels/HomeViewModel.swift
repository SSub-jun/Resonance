import Foundation
import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var status: ResonanceStatus = .running
    @Published var nowPlaying: NowPlayingInfoModel
    @Published var recentResonances: [ResonanceEvent]

    init(
        status: ResonanceStatus = .running,
        nowPlaying: NowPlayingInfoModel = .sample,
        recentResonances: [ResonanceEvent] = ResonanceEvent.sampleList
    ) {
        self.status = status
        self.nowPlaying = nowPlaying
        self.recentResonances = recentResonances
    }

    var isActive: Bool {
        status == .running
    }

    func toggle() {
        switch status {
        case .running:
            status = .paused
        case .paused:
            status = .running
        case .permissionMissing, .unavailable:
            break
        }
    }
}

extension NowPlayingInfoModel {
    static let sample = NowPlayingInfoModel(
        rawTitle: "夜行",
        normalizedTitle: "夜行",
        rawArtist: "ヨルシカ",
        normalizedArtist: "ヨルシカ",
        artworkURL: nil,
        updatedAt: Date()
    )
}

extension ResonanceEvent {
    static let sampleList: [ResonanceEvent] = [
        ResonanceEvent(
            occurredAt: Date().addingTimeInterval(-60 * 22),
            type: .sameSong,
            title: "ただ君に晴れ",
            artist: "ヨルシカ",
            locationLabel: "Shimokitazawa",
            latitude: 35.6618,
            longitude: 139.6680
        ),
        ResonanceEvent(
            occurredAt: Date().addingTimeInterval(-60 * 60 * 3),
            type: .sameArtist,
            title: "뱃노래",
            artist: "악동뮤지션",
            locationLabel: "Shibuya",
            latitude: 35.6580,
            longitude: 139.7016
        ),
        ResonanceEvent(
            occurredAt: Date().addingTimeInterval(-60 * 60 * 9),
            type: .sameSong,
            title: "Wonderwall",
            artist: "Oasis",
            locationLabel: "Harajuku",
            latitude: 35.6706,
            longitude: 139.7029
        ),
        ResonanceEvent(
            occurredAt: Date().addingTimeInterval(-60 * 60 * 27),
            type: .sameArtist,
            title: "花に亡霊",
            artist: "ヨルシカ",
            locationLabel: "Nakameguro",
            latitude: 35.6440,
            longitude: 139.6989
        ),
        ResonanceEvent(
            occurredAt: Date().addingTimeInterval(-60 * 60 * 50),
            type: .sameSong,
            title: "낙하",
            artist: "악동뮤지션",
            locationLabel: "Daikanyama",
            latitude: 35.6483,
            longitude: 139.7032
        ),
        ResonanceEvent(
            occurredAt: Date().addingTimeInterval(-60 * 60 * 74),
            type: .sameArtist,
            title: "Live Forever",
            artist: "Oasis",
            locationLabel: "Koenji",
            latitude: 35.7055,
            longitude: 139.6497
        )
    ]
}
