import SwiftUI

struct StatusIndicator: View {
    let status: ResonanceStatus

    @State private var pulse = false

    var body: some View {
        HStack(spacing: DT.Spacing.sm) {
            dot
            VStack(alignment: .leading, spacing: 2) {
                Text(status.headline)
                    .font(DT.Typography.titleMedium)
                    .foregroundColor(DT.Palette.textPrimary)
                Text(status.subline)
                    .font(DT.Typography.caption)
                    .foregroundColor(DT.Palette.textTertiary)
            }
        }
    }

    @ViewBuilder
    private var dot: some View {
        if status.showsAccentDot {
            Circle()
                .fill(DT.Palette.accent)
                .frame(width: 8, height: 8)
                .shadow(color: DT.Palette.accent.opacity(0.6), radius: 6)
                .scaleEffect(pulse ? 1.15 : 1.0)
                .opacity(pulse ? 0.75 : 1.0)
                .onAppear {
                    pulse = false
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                            pulse = true
                        }
                    }
                }
                .onDisappear {
                    pulse = false
                }
        } else {
            Circle()
                .fill(DT.Palette.textTertiary.opacity(0.4))
                .frame(width: 8, height: 8)
        }
    }
}
