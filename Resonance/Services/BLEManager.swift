import Foundation
import CoreBluetooth
import Combine

// MARK: - Protocol constants

enum BLEProtocol {
    // App-wide Resonance service. Both central and peripheral use this.
    static let serviceUUID = CBUUID(string: "5E50CE0F-0001-4A3E-8C7B-1E5FE1C4C3DE")
    static let payloadCharacteristicUUID = CBUUID(string: "5E50CE0F-0002-4A3E-8C7B-1E5FE1C4C3DE")
}

// MARK: - Payload wire format

struct BLEPayload: Codable {
    let deviceID: String
    let rawTitle: String
    let normalizedTitle: String
    let rawArtist: String
    let normalizedArtist: String
    let updatedAt: Date

    func encoded() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return try? encoder.encode(self)
    }

    static func decode(_ data: Data) -> BLEPayload? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try? decoder.decode(BLEPayload.self, from: data)
    }
}

// MARK: - Manager

@MainActor
final class BLEManager: NSObject, ObservableObject {
    static let shared = BLEManager()

    @Published private(set) var isAdvertising = false
    @Published private(set) var isScanning = false
    @Published private(set) var peripheralState: CBManagerState = .unknown
    @Published private(set) var centralState: CBManagerState = .unknown

    // Peripheral side
    private var peripheralManager: CBPeripheralManager?
    private let payloadCharacteristic = CBMutableCharacteristic(
        type: BLEProtocol.payloadCharacteristicUUID,
        properties: [.read],
        value: nil,
        permissions: [.readable]
    )

    // Central side
    private var centralManager: CBCentralManager?
    private var discovered: [UUID: CBPeripheral] = [:]
    private var pendingReads: Set<UUID> = []

    private var currentPayloadData: Data?

    private override init() {
        super.init()
    }

    // MARK: - Public control

    func start() {
        ensureManagers()
    }

    func stop() {
        peripheralManager?.stopAdvertising()
        isAdvertising = false
        centralManager?.stopScan()
        isScanning = false
        for (_, peripheral) in discovered {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        discovered.removeAll()
        pendingReads.removeAll()
    }

    /// Called whenever our Now Playing changes. Updates the characteristic value
    /// so future GATT reads return the latest info.
    func updatePayload(from info: NowPlayingInfoModel) {
        guard !info.rawTitle.isEmpty || !info.rawArtist.isEmpty else {
            currentPayloadData = nil
            return
        }
        let payload = BLEPayload(
            deviceID: ResonanceSettingsStore.shared.anonymousDeviceID,
            rawTitle: info.rawTitle,
            normalizedTitle: info.normalizedTitle,
            rawArtist: info.rawArtist,
            normalizedArtist: info.normalizedArtist,
            updatedAt: info.updatedAt
        )
        currentPayloadData = payload.encoded()
        payloadCharacteristic.value = currentPayloadData
        startAdvertisingIfReady()
    }

    // MARK: - Internals

    private func ensureManagers() {
        if peripheralManager == nil {
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        }
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil, options: [
                CBCentralManagerOptionShowPowerAlertKey: false
            ])
        }
    }

    private func startAdvertisingIfReady() {
        guard let peripheralManager, peripheralManager.state == .poweredOn else { return }
        guard currentPayloadData != nil else { return }

        if !isAdvertising {
            let service = CBMutableService(type: BLEProtocol.serviceUUID, primary: true)
            service.characteristics = [payloadCharacteristic]
            peripheralManager.removeAllServices()
            peripheralManager.add(service)
            peripheralManager.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [BLEProtocol.serviceUUID]
            ])
            isAdvertising = true
        }
    }

    private func startScanningIfReady() {
        guard let centralManager, centralManager.state == .poweredOn, !isScanning else { return }
        centralManager.scanForPeripherals(
            withServices: [BLEProtocol.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
        isScanning = true
    }
}

// MARK: - CBPeripheralManagerDelegate

extension BLEManager: CBPeripheralManagerDelegate {
    nonisolated func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        let state = peripheral.state
        Task { @MainActor in
            self.peripheralState = state
            if state == .poweredOn {
                self.startAdvertisingIfReady()
            }
        }
    }

    nonisolated func peripheralManager(_ peripheral: CBPeripheralManager,
                                       didReceiveRead request: CBATTRequest) {
        Task { @MainActor in
            guard let data = self.currentPayloadData else {
                peripheral.respond(to: request, withResult: .invalidHandle)
                return
            }
            if request.offset > data.count {
                peripheral.respond(to: request, withResult: .invalidOffset)
                return
            }
            request.value = data.subdata(in: request.offset..<data.count)
            peripheral.respond(to: request, withResult: .success)
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEManager: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state = central.state
        Task { @MainActor in
            self.centralState = state
            if state == .poweredOn {
                self.startScanningIfReady()
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                    didDiscover peripheral: CBPeripheral,
                                    advertisementData: [String : Any],
                                    rssi RSSI: NSNumber) {
        Task { @MainActor in
            guard self.discovered[peripheral.identifier] == nil else { return }
            self.discovered[peripheral.identifier] = peripheral
            peripheral.delegate = self
            central.connect(peripheral, options: nil)
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                    didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([BLEProtocol.serviceUUID])
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                    didFailToConnect peripheral: CBPeripheral,
                                    error: Error?) {
        Task { @MainActor in
            self.discovered.removeValue(forKey: peripheral.identifier)
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                    didDisconnectPeripheral peripheral: CBPeripheral,
                                    error: Error?) {
        Task { @MainActor in
            self.discovered.removeValue(forKey: peripheral.identifier)
            self.pendingReads.remove(peripheral.identifier)
        }
    }
}

// MARK: - CBPeripheralDelegate

extension BLEManager: CBPeripheralDelegate {
    nonisolated func peripheral(_ peripheral: CBPeripheral,
                                didDiscoverServices error: Error?) {
        guard error == nil, let services = peripheral.services else { return }
        for service in services where service.uuid == BLEProtocol.serviceUUID {
            peripheral.discoverCharacteristics([BLEProtocol.payloadCharacteristicUUID], for: service)
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral,
                                didDiscoverCharacteristicsFor service: CBService,
                                error: Error?) {
        guard error == nil, let characteristics = service.characteristics else { return }
        for characteristic in characteristics where characteristic.uuid == BLEProtocol.payloadCharacteristicUUID {
            peripheral.readValue(for: characteristic)
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral,
                                didUpdateValueFor characteristic: CBCharacteristic,
                                error: Error?) {
        guard error == nil, let data = characteristic.value else { return }
        guard let payload = BLEPayload.decode(data) else { return }

        Task { @MainActor in
            let own = NowPlayingManager.shared.info
            let peerPayload = PeerPayload(
                anonymousDeviceID: payload.deviceID,
                rawTitle: payload.rawTitle,
                normalizedTitle: payload.normalizedTitle,
                rawArtist: payload.rawArtist,
                normalizedArtist: payload.normalizedArtist,
                updatedAt: payload.updatedAt
            )
            _ = ResonanceDetector.shared.evaluate(peer: peerPayload, own: own)

            // Disconnect to free the slot for future rediscovery
            self.centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
}
