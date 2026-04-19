import Foundation
import CoreLocation
import MapKit

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var events: [ResonanceEvent]
    @Published var region: MKCoordinateRegion
    @Published var selectedEventID: UUID?
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: String?

    init(
        events: [ResonanceEvent],
        center: CLLocationCoordinate2D? = nil,
        initialSelection: UUID? = nil
    ) {
        self.events = events
        self.selectedEventID = initialSelection

        let fallback = CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016)
        let preselectedCoord = initialSelection
            .flatMap { id in events.first(where: { $0.id == id })?.coordinate }
        let resolvedCenter = center
            ?? preselectedCoord
            ?? events.compactMap(\.coordinate).first
            ?? fallback
        let zoomSpan: CLLocationDegrees = initialSelection != nil ? 0.02 : 0.035

        self.region = MKCoordinateRegion(
            center: resolvedCenter,
            span: MKCoordinateSpan(latitudeDelta: zoomSpan, longitudeDelta: zoomSpan)
        )
    }

    var plottableEvents: [ResonanceEvent] {
        events.filter { $0.coordinate != nil }
    }

    var selectedEvent: ResonanceEvent? {
        guard let id = selectedEventID else { return nil }
        return events.first(where: { $0.id == id })
    }

    func select(_ event: ResonanceEvent) {
        selectedEventID = event.id
        if let coord = event.coordinate {
            region = MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }

    func clearSelection() {
        selectedEventID = nil
    }

    /// Fetch events from Supabase. Merges with any existing local/sample list,
    /// preferring server rows when IDs collide.
    func refreshFromServer() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let remote = try await ResonanceAPIClient.shared.fetchMyEvents(limit: 100)
            let keepLocal = events.filter { local in
                !remote.contains(where: { $0.id == local.id })
            }
            self.events = (remote + keepLocal).sorted { $0.occurredAt > $1.occurredAt }
            self.lastError = nil
        } catch {
            self.lastError = String(describing: error)
        }
    }

    func delete(_ event: ResonanceEvent) async {
        events.removeAll { $0.id == event.id }
        if selectedEventID == event.id { selectedEventID = nil }
        try? await ResonanceAPIClient.shared.deleteEvent(id: event.id)
    }
}
