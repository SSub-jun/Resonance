import Foundation
import Combine
import SwiftUI

@MainActor
final class AppLifecycleCoordinator: ObservableObject {
    static let shared = AppLifecycleCoordinator()

    private var cancellables = Set<AnyCancellable>()
    private var started = false

    private init() {}

    /// Called once on app launch.
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

        // Detected resonance → persist to server (or enqueue on failure)
        ResonanceEventBus.shared.events
            .receive(on: RunLoop.main)
            .sink { event in
                Task { await AppLifecycleCoordinator.persist(event) }
            }
            .store(in: &cancellables)

        // Register device + drain any queued events
        Task { await registerAndDrain() }
    }

    /// Called on scenePhase transitions to .active.
    func onBecameActive() {
        let enabled = ResonanceSettingsStore.shared.resonanceEnabled
        applyEnabled(enabled)
        NowPlayingManager.shared.refresh()
        Task { await registerAndDrain() }
    }

    // MARK: - Helpers

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

    private func registerAndDrain() async {
        let deviceID = ResonanceSettingsStore.shared.anonymousDeviceID
        do {
            _ = try await ResonanceAPIClient.shared.ensureRegistered(deviceID: deviceID)
            await OfflineEventQueue.shared.drain(deviceID: deviceID)
        } catch {
            // Network or server hiccup — next activation retries.
        }
    }

    /// Persist a single resonance event. Falls back to offline queue on failure.
    static func persist(_ event: ResonanceEvent) async {
        let deviceID = await ResonanceSettingsStore.shared.anonymousDeviceID
        do {
            _ = try await ResonanceAPIClient.shared.saveEvent(event, deviceID: deviceID)
        } catch {
            await OfflineEventQueue.shared.enqueue(event)
        }
    }
}
