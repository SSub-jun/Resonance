import SwiftUI

struct ResonanceBanner: View {
    let type: ResonanceType
    let title: String
    let artist: String
    var autoDismissAfter: TimeInterval? = 3.0
    var onDismiss: (() -> Void)? = nil

    @State private var appeared = false

    var body: some View {
        GlassCard(
            padding: DT.Spacing.md,
            accentBorderColor: DT.Palette.accent.opacity(type.accentOpacity * 0.4),
            accentBorderWidth: 1,
            glowColor: DT.Palette.accent.opacity(type.accentOpacity * 0.55),
            glowRadius: type.glowRadius
        ) {
            VStack(alignment: .leading, spacing: DT.Spacing.sm) {
                HStack(spacing: DT.Spacing.sm) {
                    Circle()
                        .fill(DT.Palette.accent.opacity(type.accentOpacity))
                        .frame(width: 6, height: 6)
                    Text(type.label)
                        .font(DT.Typography.label)
                        .foregroundColor(DT.Palette.accent.opacity(type.accentOpacity))
                        .tracking(1.2)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DT.Typography.titleMedium)
                        .foregroundColor(DT.Palette.textPrimary)
                        .lineLimit(1)
                    Text(artist)
                        .font(DT.Typography.body)
                        .foregroundColor(DT.Palette.textSecondary)
                        .lineLimit(1)
                }
            }
        }
        .scaleEffect(appeared ? 1.0 : 0.985)
        .opacity(appeared ? 1.0 : 0.0)
        .onAppear {
            withAnimation(DT.Motion.resonance) {
                appeared = true
            }
            scheduleAutoDismiss()
        }
    }

    private func scheduleAutoDismiss() {
        guard let delay = autoDismissAfter, let onDismiss else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(DT.Motion.standard) {
                appeared = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onDismiss()
            }
        }
    }
}
