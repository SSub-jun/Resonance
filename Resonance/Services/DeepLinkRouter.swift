import Foundation
import SwiftUI

@MainActor
final class DeepLinkRouter: ObservableObject {
    static let shared = DeepLinkRouter()

    @Published var pendingEventID: UUID?

    private init() {}

    func consume() -> UUID? {
        let id = pendingEventID
        pendingEventID = nil
        return id
    }
}
