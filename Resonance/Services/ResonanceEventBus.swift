import Foundation
import Combine

@MainActor
final class ResonanceEventBus: ObservableObject {
    static let shared = ResonanceEventBus()

    let events = PassthroughSubject<ResonanceEvent, Never>()

    private init() {}

    func publish(_ event: ResonanceEvent) {
        events.send(event)
    }
}
