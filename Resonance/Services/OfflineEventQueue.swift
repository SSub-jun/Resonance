import Foundation

struct QueuedResonanceEvent: Codable, Identifiable {
    let id: UUID
    let occurredAt: Date
    let typeRaw: String
    let rawTitle: String
    let rawArtist: String
    let latitude: Double?
    let longitude: Double?

    init(event: ResonanceEvent) {
        self.id = event.id
        self.occurredAt = event.occurredAt
        self.typeRaw = event.type.rawValue
        self.rawTitle = event.title
        self.rawArtist = event.artist
        self.latitude = event.latitude
        self.longitude = event.longitude
    }

    func toDomain() -> ResonanceEvent? {
        guard let type = ResonanceType(rawValue: typeRaw) else { return nil }
        return ResonanceEvent(
            id: id,
            occurredAt: occurredAt,
            type: type,
            title: rawTitle,
            artist: rawArtist,
            locationLabel: nil,
            latitude: latitude,
            longitude: longitude
        )
    }
}

@MainActor
final class OfflineEventQueue {
    static let shared = OfflineEventQueue()

    private static let defaultsKey = "kyomei.offlineQueue"
    private var draining = false

    private init() {}

    func enqueue(_ event: ResonanceEvent) {
        var current = load()
        current.append(QueuedResonanceEvent(event: event))
        save(current)
    }

    var count: Int { load().count }

    /// Attempt to POST every queued event. Successful items drop out of the queue.
    /// Failures stay for the next drain attempt.
    func drain(deviceID: String, client: ResonanceAPIClient = .shared) async {
        guard !draining else { return }
        draining = true
        defer { draining = false }

        var pending = load()
        guard !pending.isEmpty else { return }

        var successes: Set<UUID> = []
        for item in pending {
            guard let event = item.toDomain() else {
                successes.insert(item.id)
                continue
            }
            do {
                _ = try await client.saveEvent(event, deviceID: deviceID)
                successes.insert(item.id)
            } catch {
                // Keep in queue for retry.
            }
        }

        pending.removeAll { successes.contains($0.id) }
        save(pending)
    }

    // MARK: - Persistence

    private func load() -> [QueuedResonanceEvent] {
        guard let data = UserDefaults.standard.data(forKey: Self.defaultsKey) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([QueuedResonanceEvent].self, from: data)) ?? []
    }

    private func save(_ queue: [QueuedResonanceEvent]) {
        let encoder = JSONEncoder()
        if queue.isEmpty {
            UserDefaults.standard.removeObject(forKey: Self.defaultsKey)
            return
        }
        if let data = try? encoder.encode(queue) {
            UserDefaults.standard.set(data, forKey: Self.defaultsKey)
        }
    }
}
