import Foundation
import CoreBluetooth
import CoreLocation

@MainActor
final class PermissionCoordinator: NSObject, ObservableObject {
    static let shared = PermissionCoordinator()

    @Published var locationStatus: CLAuthorizationStatus
    @Published var bluetoothState: CBManagerState = .unknown

    private let locationManager = CLLocationManager()
    private var centralManager: CBCentralManager?

    private override init() {
        self.locationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
    }

    func requestAll() {
        requestLocation()
        requestBluetooth()
    }

    func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    func requestBluetooth() {
        guard centralManager == nil else { return }
        let options: [String: Any] = [
            CBCentralManagerOptionShowPowerAlertKey: false
        ]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
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
