import Foundation

@MainActor
final class ResonanceSettingsStore: ObservableObject {
    static let shared = ResonanceSettingsStore()

    private enum Key {
        static let resonanceEnabled = "resonance.enabled"
        static let anonymousDeviceID = "resonance.anonymousDeviceID"
    }

    @Published var resonanceEnabled: Bool {
        didSet {
            UserDefaults.standard.set(resonanceEnabled, forKey: Key.resonanceEnabled)
        }
    }

    let anonymousDeviceID: String

    private init() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: Key.resonanceEnabled) == nil {
            defaults.set(true, forKey: Key.resonanceEnabled)
        }
        self.resonanceEnabled = defaults.bool(forKey: Key.resonanceEnabled)

        if let existing = defaults.string(forKey: Key.anonymousDeviceID), !existing.isEmpty {
            self.anonymousDeviceID = existing
        } else {
            let generated = UUID().uuidString
            defaults.set(generated, forKey: Key.anonymousDeviceID)
            self.anonymousDeviceID = generated
        }
    }
}
