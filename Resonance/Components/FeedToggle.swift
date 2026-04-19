import SwiftUI

enum FeedMode: String, CaseIterable, Identifiable {
    case map = "Map"
    case list = "List"
    var id: String { rawValue }
}

struct FeedToggle: View {
    @Binding var selection: FeedMode

    var body: some View {
        HStack(spacing: 4) {
            ForEach(FeedMode.allCases) { mode in
                segment(for: mode)
            }
        }
        .padding(3)
        .background(
            Capsule().fill(DT.Palette.glassFill)
        )
        .overlay(
            Capsule().strokeBorder(DT.Palette.glassBorder, lineWidth: 1)
        )
    }

    private func segment(for mode: FeedMode) -> some View {
        let isSelected = selection == mode
        return Button {
            withAnimation(DT.Motion.quick) { selection = mode }
        } label: {
            Text(mode.rawValue)
                .font(DT.Typography.label)
                .tracking(1.0)
                .foregroundColor(isSelected ? DT.Palette.textPrimary : DT.Palette.textTertiary)
                .padding(.horizontal, DT.Spacing.md)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white.opacity(0.08) : Color.clear)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
