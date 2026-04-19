import SwiftUI

struct HomeBottomPanel: View {
    let selectedEvent: ResonanceEvent?
    let recent: [ResonanceEvent]
    var onSelectEvent: (ResonanceEvent) -> Void
    var onOpenList: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let event = selectedEvent {
                detailSection(event: event)
                divider
            }

            recentHeader
            recentRows
        }
        .background(panelBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(DT.Palette.glassBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Detail section (pin selected)

    private func detailSection(event: ResonanceEvent) -> some View {
        HStack(alignment: .center, spacing: DT.Spacing.md) {
            ResonancePinView(type: event.type, isSelected: true)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(DT.Typography.titleMedium)
                    .foregroundColor(DT.Palette.textPrimary)
                    .lineLimit(1)

                Text(event.artist)
                    .font(DT.Typography.body)
                    .foregroundColor(DT.Palette.textSecondary)
                    .lineLimit(1)

                Text(metadataLine(for: event))
                    .font(DT.Typography.caption)
                    .foregroundColor(DT.Palette.textTertiary)
                    .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, DT.Spacing.md)
        .padding(.vertical, 12)
    }

    // MARK: - Recent

    private var recentHeader: some View {
        HStack {
            Text("Recent")
                .font(DT.Typography.label)
                .foregroundColor(DT.Palette.textTertiary)
                .tracking(1.2)

            Spacer()

            Button(action: onOpenList) {
                HStack(spacing: 4) {
                    Text("LIST")
                        .font(DT.Typography.label)
                        .tracking(1.2)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(DT.Palette.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, DT.Spacing.md)
        .padding(.trailing, 6)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    private var recentRows: some View {
        VStack(spacing: 0) {
            let visible = Array(recent.prefix(2))
            ForEach(Array(visible.enumerated()), id: \.element.id) { index, event in
                Button {
                    onSelectEvent(event)
                } label: {
                    CompactRecentRow(event: event)
                }
                .buttonStyle(.plain)

                if index < visible.count - 1 {
                    Rectangle()
                        .fill(DT.Palette.glassBorder)
                        .frame(height: 0.5)
                        .padding(.horizontal, DT.Spacing.md)
                }
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private var panelBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(DT.Palette.background.opacity(0.78))
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.55))
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(DT.Palette.glassBorder)
            .frame(height: 0.5)
    }

    private func metadataLine(for event: ResonanceEvent) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, HH:mm"
        let date = formatter.string(from: event.occurredAt)
        if let loc = event.locationLabel, !loc.isEmpty {
            return "\(date) · \(loc)"
        }
        return date
    }
}

private struct CompactRecentRow: View {
    let event: ResonanceEvent

    var body: some View {
        HStack(spacing: DT.Spacing.md) {
            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(DT.Typography.body)
                    .foregroundColor(DT.Palette.textPrimary)
                    .lineLimit(1)
                Text(event.artist)
                    .font(DT.Typography.caption)
                    .foregroundColor(DT.Palette.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: DT.Spacing.sm)

            Image(systemName: event.type == .sameSong ? "music.note" : "person.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DT.Palette.accent)
                .frame(width: 30, height: 30)
                .background(Circle().fill(DT.Palette.glassFill))
                .overlay(Circle().strokeBorder(DT.Palette.glassBorder, lineWidth: 0.5))
        }
        .padding(.horizontal, DT.Spacing.md)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
