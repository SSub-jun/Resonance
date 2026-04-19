import SwiftUI

struct HomeTopOverlay: View {
    let status: ResonanceStatus
    var onAction: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: DT.Spacing.md) {
            statusCapsule
            Spacer(minLength: DT.Spacing.sm)
            actionCapsule
        }
    }

    private var statusCapsule: some View {
        HStack(spacing: DT.Spacing.sm) {
            StatusDot(status: status)
            VStack(alignment: .leading, spacing: 1) {
                Text(status.headline)
                    .font(DT.Typography.label)
                    .foregroundColor(DT.Palette.textPrimary)
                    .tracking(0.9)
                Text(status.subline)
                    .font(DT.Typography.caption)
                    .foregroundColor(DT.Palette.textTertiary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, DT.Spacing.md)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(DT.Palette.background.opacity(0.72))
        )
        .background(
            Capsule().fill(.ultraThinMaterial.opacity(0.5))
        )
        .overlay(
            Capsule().strokeBorder(DT.Palette.glassBorder, lineWidth: 1)
        )
    }

    private var actionCapsule: some View {
        Button(action: onAction) {
            Text(status.actionLabel)
                .font(DT.Typography.label)
                .foregroundColor(DT.Palette.textSecondary)
                .tracking(1.0)
                .padding(.horizontal, DT.Spacing.md)
                .padding(.vertical, 8)
                .background(Capsule().fill(DT.Palette.background.opacity(0.72)))
                .background(Capsule().fill(.ultraThinMaterial.opacity(0.5)))
                .overlay(Capsule().strokeBorder(DT.Palette.glassBorder, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct StatusDot: View {
    let status: ResonanceStatus
    @State private var pulse = false

    var body: some View {
        Group {
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
                    .onDisappear { pulse = false }
            } else {
                Circle()
                    .fill(DT.Palette.textTertiary.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
