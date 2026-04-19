import SwiftUI

enum DT {
    enum Palette {
        static let background = Color(hex: 0x0A0A0D)
        static let accent = Color(hex: 0x7C5CFF)

        static let accentStrong = accent
        static let accentWeak = accent.opacity(0.35)

        static let glassFill = Color.white.opacity(0.05)
        static let glassBorder = Color.white.opacity(0.08)

        static let textPrimary = Color.white.opacity(0.92)
        static let textSecondary = Color.white.opacity(0.64)
        static let textTertiary = Color.white.opacity(0.40)
    }

    enum Glass {
        static let blurRadius: CGFloat = 24
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 1
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Motion {
        static let standard = Animation.easeInOut(duration: 0.3)
        static let quick = Animation.easeInOut(duration: 0.25)
        static let resonance = Animation.easeInOut(duration: 0.35)
    }

    enum Typography {
        static let titleLarge = Font.system(size: 30, weight: .semibold, design: .default)
        static let titleMedium = Font.system(size: 19, weight: .medium, design: .default)
        static let label = Font.system(size: 13, weight: .medium, design: .default).smallCaps()
        static let body = Font.system(size: 15, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex & 0xFF0000) >> 16) / 255.0
        let g = Double((hex & 0x00FF00) >> 8) / 255.0
        let b = Double(hex & 0x0000FF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
