import Foundation
import SwiftUI

enum ResonanceType: String, Codable, Hashable {
    case sameSong = "same_song"
    case sameArtist = "same_artist"

    var label: String {
        switch self {
        case .sameSong: return "Same Song"
        case .sameArtist: return "Same Artist"
        }
    }

    var accentOpacity: Double {
        switch self {
        case .sameSong: return 1.0
        case .sameArtist: return 0.35
        }
    }

    var glowRadius: CGFloat {
        switch self {
        case .sameSong: return 18
        case .sameArtist: return 8
        }
    }
}
