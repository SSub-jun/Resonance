import Foundation
import CoreLocation

enum ResonanceAPIError: Error {
    case invalidResponse
    case http(Int, Data?)
    case decoding(Error)
}

/// Payload shapes for Supabase rows.
struct RemoteResonanceEvent: Codable {
    let id: UUID
    let user_id: UUID
    let occurred_at: Date
    let resonance_type: String
    let raw_title: String?
    let normalized_title: String?
    let raw_artist: String?
    let normalized_artist: String?
    let my_latitude: Double?
    let my_longitude: Double?
    let app_version: String?
    let created_at: Date?

    func toDomain() -> ResonanceEvent? {
        guard let type = ResonanceType(rawValue: resonance_type) else { return nil }
        return ResonanceEvent(
            id: id,
            occurredAt: occurred_at,
            type: type,
            title: raw_title ?? "",
            artist: raw_artist ?? "",
            locationLabel: nil,
            latitude: my_latitude,
            longitude: my_longitude
        )
    }
}

struct NewResonanceEvent: Codable {
    let user_id: UUID
    let occurred_at: Date
    let resonance_type: String
    let raw_title: String?
    let normalized_title: String?
    let raw_artist: String?
    let normalized_artist: String?
    let my_latitude: Double?
    let my_longitude: Double?
    let app_version: String?
}

private struct RemoteUser: Codable {
    let id: UUID
    let device_id: String
    let created_at: Date
}

@MainActor
final class ResonanceAPIClient {
    static let shared = ResonanceAPIClient()

    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private static let userIDDefaultsKey = "kyomei.userID"

    private init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.timeoutIntervalForRequest = 12
        config.timeoutIntervalForResource = 20
        self.session = URLSession(configuration: config)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { d in
            let c = try d.singleValueContainer()
            let s = try c.decode(String.self)
            if let date = iso.date(from: s) { return date }
            let fallback = ISO8601DateFormatter()
            if let date = fallback.date(from: s) { return date }
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unrecognized date: \(s)")
        }
        self.decoder = decoder
    }

    // MARK: - User registration

    private(set) var userID: UUID? {
        get {
            guard let s = UserDefaults.standard.string(forKey: Self.userIDDefaultsKey) else { return nil }
            return UUID(uuidString: s)
        }
        set {
            if let v = newValue {
                UserDefaults.standard.set(v.uuidString, forKey: Self.userIDDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.userIDDefaultsKey)
            }
        }
    }

    /// Upsert our anonymous device row in Supabase and cache the returned user_id.
    @discardableResult
    func ensureRegistered(deviceID: String) async throws -> UUID {
        if let existing = userID { return existing }

        // Try to find an existing row first; avoids unique-violation noise.
        if let found = try await fetchUser(deviceID: deviceID) {
            self.userID = found
            return found
        }

        // INSERT with return=representation to get the id back.
        var url = SupabaseConfig.restURL(SupabaseConfig.Table.users)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        SupabaseConfig.applyDefaultHeaders(&req)
        req.setValue("return=representation", forHTTPHeaderField: "Prefer")
        req.httpBody = try encoder.encode(["device_id": deviceID])

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw ResonanceAPIError.invalidResponse }
        if http.statusCode == 409 {
            // Race: row appeared between our SELECT and INSERT. Re-fetch.
            if let found = try await fetchUser(deviceID: deviceID) {
                self.userID = found
                return found
            }
            throw ResonanceAPIError.http(http.statusCode, data)
        }
        guard (200...299).contains(http.statusCode) else {
            throw ResonanceAPIError.http(http.statusCode, data)
        }
        let rows: [RemoteUser]
        do {
            rows = try decoder.decode([RemoteUser].self, from: data)
        } catch {
            throw ResonanceAPIError.decoding(error)
        }
        guard let row = rows.first else { throw ResonanceAPIError.invalidResponse }
        self.userID = row.id
        return row.id
    }

    private func fetchUser(deviceID: String) async throws -> UUID? {
        var comps = URLComponents(url: SupabaseConfig.restURL(SupabaseConfig.Table.users),
                                  resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "device_id", value: "eq.\(deviceID)"),
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "limit", value: "1")
        ]
        var req = URLRequest(url: comps.url!)
        SupabaseConfig.applyDefaultHeaders(&req)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            return nil
        }
        let rows = (try? decoder.decode([RemoteUser].self, from: data)) ?? []
        return rows.first?.id
    }

    // MARK: - Events

    @discardableResult
    func saveEvent(_ event: ResonanceEvent, deviceID: String) async throws -> UUID {
        let userID = try await ensureRegistered(deviceID: deviceID)

        let body = NewResonanceEvent(
            user_id: userID,
            occurred_at: event.occurredAt,
            resonance_type: event.type.rawValue,
            raw_title: event.title.isEmpty ? nil : event.title,
            normalized_title: StringNormalizer.normalizeTitle(event.title),
            raw_artist: event.artist.isEmpty ? nil : event.artist,
            normalized_artist: StringNormalizer.normalizeArtist(event.artist),
            my_latitude: event.latitude,
            my_longitude: event.longitude,
            app_version: SupabaseConfig.appVersion
        )

        var req = URLRequest(url: SupabaseConfig.restURL(SupabaseConfig.Table.events))
        req.httpMethod = "POST"
        SupabaseConfig.applyDefaultHeaders(&req)
        req.setValue("return=representation", forHTTPHeaderField: "Prefer")
        req.httpBody = try encoder.encode(body)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw ResonanceAPIError.http((resp as? HTTPURLResponse)?.statusCode ?? -1, data)
        }
        let rows = try decoder.decode([RemoteResonanceEvent].self, from: data)
        guard let row = rows.first else { throw ResonanceAPIError.invalidResponse }
        return row.id
    }

    func fetchMyEvents(limit: Int = 50) async throws -> [ResonanceEvent] {
        guard let userID = self.userID else { return [] }

        var comps = URLComponents(url: SupabaseConfig.restURL(SupabaseConfig.Table.events),
                                  resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)"),
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "order", value: "occurred_at.desc"),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        var req = URLRequest(url: comps.url!)
        SupabaseConfig.applyDefaultHeaders(&req)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw ResonanceAPIError.http((resp as? HTTPURLResponse)?.statusCode ?? -1, data)
        }
        let rows = try decoder.decode([RemoteResonanceEvent].self, from: data)
        return rows.compactMap { $0.toDomain() }
    }

    func deleteEvent(id: UUID) async throws {
        var comps = URLComponents(url: SupabaseConfig.restURL(SupabaseConfig.Table.events),
                                  resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "id", value: "eq.\(id.uuidString)")]

        var req = URLRequest(url: comps.url!)
        req.httpMethod = "DELETE"
        SupabaseConfig.applyDefaultHeaders(&req)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw ResonanceAPIError.http((resp as? HTTPURLResponse)?.statusCode ?? -1, data)
        }
    }
}
