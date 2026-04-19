import SwiftUI

struct ResonanceDetailCard: View {
    let event: ResonanceEvent

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMM d, HH:mm"
        return f
    }()

    var body: some View {
        GlassCard(
            padding: DT.Spacing.md,
            backgroundFill: DT.Palette.background.opacity(0.82),
            accentBorderColor: DT.Palette.accent.opacity(event.type.accentOpacity * 0.45),
            accentBorderWidth: 1,
            glowColor: DT.Palette.accent.opacity(event.type.accentOpacity * 0.4),
            glowRadius: 14
        ) {
            HStack(alignment: .center, spacing: DT.Spacing.md) {
                ResonancePinView(type: event.type, isSelected: true)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(DT.Typography.titleMedium)
                        .foregroundColor(DT.Palette.textPrimary)
                        .lineLimit(1)

                    Text(event.artist)
                        .font(DT.Typography.body)
                        .foregroundColor(DT.Palette.textSecondary)
                        .lineLimit(1)

                    Text(metadataLine)
                        .font(DT.Typography.caption)
                        .foregroundColor(DT.Palette.textTertiary)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var metadataLine: String {
        let date = Self.formatter.string(from: event.occurredAt)
        if let loc = event.locationLabel, !loc.isEmpty {
            return "\(date) · \(loc)"
        }
        return date
    }
}
