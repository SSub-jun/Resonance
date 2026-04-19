import Foundation

enum ResonanceStatus {
    case running
    case paused
    case permissionMissing
    case unavailable

    var headline: String {
        switch self {
        case .running: return "Resonance Active"
        case .paused: return "Paused"
        case .permissionMissing: return "Permission Required"
        case .unavailable: return "Unavailable"
        }
    }

    var subline: String {
        switch self {
        case .running: return "Running in background"
        case .paused: return "Tap to resume"
        case .permissionMissing: return "Allow location and bluetooth to start"
        case .unavailable: return "Bluetooth or location is not available"
        }
    }

    var actionLabel: String {
        switch self {
        case .running: return "Stop"
        case .paused: return "Resume"
        case .permissionMissing: return "Open Settings"
        case .unavailable: return "Open Settings"
        }
    }

    var showsAccentDot: Bool {
        self == .running
    }
}
