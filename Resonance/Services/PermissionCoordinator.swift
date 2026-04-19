import Foundation
import CoreBluetooth
import CoreLocation
import MediaPlayer

@MainActor
final class PermissionCoordinator: NSObject, ObservableObject {
    static let shared = PermissionCoordinator()

    @Published var locationStatus: CLAuthorizationStatus
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var mediaLibraryStatus: MPMediaLibraryAuthorizationStatus

    private let locationManager = CLLocationManager()
    private var centralManager: CBCentralManager?

    private override init() {
        self.locationStatus = locationManager.authorizationStatus
        self.mediaLibraryStatus = MPMediaLibrary.authorizationStatus()
        super.init()
        locationManager.delegate = self
    }

    func requestAll() {
        requestLocation()
        requestBluetooth()
        requestMediaLibrary()
    }

    func requestLocation() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func requestBluetooth() {
        guard centralManager == nil else { return }
        let options: [String: Any] = [CBCentralManagerOptionShowPowerAlertKey: false]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
    }

    func requestMediaLibrary() {
        let currentStatus = MPMediaLibrary.authorizationStatus()
        self.mediaLibraryStatus = currentStatus
        guard currentStatus == .notDetermined else {
            if currentStatus == .authorized {
                NowPlayingManager.shared.refresh()
            }
            return
        }
        MPMediaLibrary.requestAuthorization { [weak self] status in
            Task { @MainActor in
                self?.mediaLibraryStatus = status
                if status == .authorized {
                    NowPlayingManager.shared.refresh()
                }
            }
        }
    }
}

extension PermissionCoordinator: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.locationStatus = status
        }
    }
}

extension PermissionCoordinator: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state = central.state
        Task { @MainActor in
            self.bluetoothState = state
        }
    }
}
