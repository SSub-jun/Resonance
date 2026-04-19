import SwiftUI

struct ArchiveRow: View {
    let event: ResonanceEvent

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMM d"
        return f
    }()

    var body: some View {
        HStack(alignment: .center, spacing: DT.Spacing.md) {
            VStack(alignment: .leading, spacing: DT.Spacing.xs) {
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
            }

            Spacer(minLength: DT.Spacing.md)

            typeIcon
        }
        .padding(.vertical, DT.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var typeIcon: some View {
        Image(systemName: event.type == .sameSong ? "music.note" : "person.fill")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(DT.Palette.accent)
            .frame(width: 32, height: 32)
            .background(Circle().fill(DT.Palette.glassFill))
            .overlay(Circle().strokeBorder(DT.Palette.glassBorder, lineWidth: 1))
            .accessibilityLabel(Text(event.type.label))
    }

    private var metadataLine: String {
        let date = Self.dateFormatter.string(from: event.occurredAt)
        if let loc = event.locationLabel, !loc.isEmpty {
            return "\(date) · \(loc)"
        }
        return date
    }
}
