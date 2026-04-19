import Foundation
import CoreLocation

struct ResonanceEvent: Identifiable, Hashable {
    let id: UUID
    let occurredAt: Date
    let type: ResonanceType
    let title: String
    let artist: String
    let locationLabel: String?
    let latitude: Double?
    let longitude: Double?

    init(
        id: UUID = UUID(),
        occurredAt: Date,
        type: ResonanceType,
        title: String,
        artist: String,
        locationLabel: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.occurredAt = occurredAt
        self.type = type
        self.title = title
        self.artist = artist
        self.locationLabel = locationLabel
        self.latitude = latitude
        self.longitude = longitude
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
