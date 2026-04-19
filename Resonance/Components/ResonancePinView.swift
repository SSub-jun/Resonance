import SwiftUI

struct ResonancePinView: View {
    let type: ResonanceType
    var isSelected: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(DT.Palette.accent.opacity(isSelected ? 0.38 : 0.22))
                .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                .blur(radius: 6)

            Circle()
                .fill(DT.Palette.background)
                .frame(width: 30, height: 30)
                .overlay(
                    Circle().strokeBorder(DT.Palette.accent, lineWidth: 1.2)
                )

            Image(systemName: iconName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DT.Palette.accent)
        }
        .shadow(color: DT.Palette.accent.opacity(0.45), radius: isSelected ? 10 : 4)
        .animation(DT.Motion.quick, value: isSelected)
    }

    private var iconName: String {
        switch type {
        case .sameSong: return "music.note"
        case .sameArtist: return "person.fill"
        }
    }
}
