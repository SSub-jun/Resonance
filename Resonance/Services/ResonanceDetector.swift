import Foundation
import CoreLocation

struct PeerPayload {
    let anonymousDeviceID: String
    let rawTitle: String
    let normalizedTitle: String
    let rawArtist: String
    let normalizedArtist: String
    let updatedAt: Date
}

@MainActor
final class ResonanceDetector {
    static let shared = ResonanceDetector()

    private struct MatchKey: Hashable {
        let peerID: String
        let type: ResonanceType
        let targetHash: String
    }

    private var lastMatches: [MatchKey: Date] = [:]
    private let cooldown: TimeInterval = 90

    private init() {}

    /// Evaluate a peer payload against our own current Now Playing info.
    /// If a new resonance is detected (not within cooldown), publishes it
    /// to ResonanceEventBus and returns the event.
    @discardableResult
    func evaluate(peer: PeerPayload, own: NowPlayingInfoModel) -> ResonanceEvent? {
        guard own.normalizedTitle.isEmpty == false || own.normalizedArtist.isEmpty == false else {
            return nil
        }

        let type: ResonanceType?
        let targetHash: String

        if !own.normalizedTitle.isEmpty, own.normalizedTitle == peer.normalizedTitle {
            type = .sameSong
            targetHash = peer.normalizedTitle
        } else if !own.normalizedArtist.isEmpty, own.normalizedArtist == peer.normalizedArtist {
            type = .sameArtist
            targetHash = peer.normalizedArtist
        } else {
            return nil
        }

        guard let resonanceType = type else { return nil }

        let key = MatchKey(peerID: peer.anonymousDeviceID, type: resonanceType, targetHash: targetHash)
        if let last = lastMatches[key], Date().timeIntervalSince(last) < cooldown {
            return nil
        }
        lastMatches[key] = Date()

        let coordinate = LocationManager.shared.snapshot()

        let event = ResonanceEvent(
            occurredAt: Date(),
            type: resonanceType,
            title: peer.rawTitle,
            artist: peer.rawArtist,
            locationLabel: nil,
            latitude: coordinate?.latitude,
            longitude: coordinate?.longitude
        )

        ResonanceEventBus.shared.publish(event)
        return event
    }

    func resetCooldowns() {
        lastMatches.removeAll()
    }
}
