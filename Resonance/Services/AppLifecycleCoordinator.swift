import Foundation
import Combine
import SwiftUI

@MainActor
final class AppLifecycleCoordinator: ObservableObject {
    static let shared = AppLifecycleCoordinator()

    private var cancellables = Set<AnyCancellable>()
    private var started = false

    private init() {}

    /// Called once on app launch. Wires up cross-service observations so that
    /// (a) NowPlayingManager updates flow into BLEManager's advertised payload,
    /// (b) BLE starts whenever the toggle is on and permissions allow.
    func bootstrap() {
        guard !started else { return }
        started = true

        // NowPlaying → BLE payload pipeline
        NowPlayingManager.shared.$info
            .receive(on: RunLoop.main)
            .sink { info in
                BLEManager.shared.updatePayload(from: info)
            }
            .store(in: &cancellables)

        // Settings toggle → start/stop BLE + location
        ResonanceSettingsStore.shared.$resonanceEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                self?.applyEnabled(enabled)
            }
            .store(in: &cancellables)
    }

    /// Called on scenePhase transitions. Runs a lightweight health check.
    func onBecameActive() {
        let enabled = ResonanceSettingsStore.shared.resonanceEnabled
        applyEnabled(enabled)
        NowPlayingManager.shared.refresh()
    }

    // MARK: - Internal

    private func applyEnabled(_ enabled: Bool) {
        if enabled {
            LocationManager.shared.startMonitoring()
            BLEManager.shared.start()
            BLEManager.shared.updatePayload(from: NowPlayingManager.shared.info)
        } else {
            BLEManager.shared.stop()
            LocationManager.shared.stopMonitoring()
        }
    }
}
