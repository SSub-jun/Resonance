import SwiftUI

struct HomeBottomPanel: View {
    let nowPlaying: NowPlayingInfoModel
    let isActive: Bool
    let recent: [ResonanceEvent]
    var onSelectEvent: (ResonanceEvent) -> Void
    var onOpenList: () -> Void

    var body: some View {
        ZStack {
            if isActive {
                ResonanceRipple(cornerRadius: 22)
                    .allowsHitTesting(false)
            }

            VStack(spacing: 0) {
                nowPlayingRow
                if !recent.isEmpty {
                    divider
                    recentRows
                }
            }
            .background(panelBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(DT.Palette.glassBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private var panelBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(DT.Palette.background.opacity(0.78))
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.55))
        }
    }

    // MARK: - Now Playing row

    private var nowPlayingRow: some View {
        HStack(spacing: DT.Spacing.md) {
            artwork

            VStack(alignment: .leading, spacing: 2) {
                Text("Now Playing")
                    .font(DT.Typography.label)
                    .foregroundColor(DT.Palette.textTertiary)
                    .tracking(1.2)

                Text(nowPlaying.rawTitle.isEmpty ? "Nothing is playing" : nowPlaying.rawTitle)
                    .font(DT.Typography.titleMedium)
                    .foregroundColor(DT.Palette.textPrimary)
                    .lineLimit(1)

                Text(nowPlaying.rawArtist.isEmpty ? "—" : nowPlaying.rawArtist)
                    .font(DT.Typography.caption)
                    .foregroundColor(DT.Palette.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, DT.Spacing.md)
        .padding(.vertical, 12)
    }

    private var artwork: some View {
        Group {
            if let url = nowPlaying.artworkURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        artworkPlaceholder
                    }
                }
            } else {
                artworkPlaceholder
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(DT.Palette.glassBorder, lineWidth: 0.5)
        )
    }

    private var artworkPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(DT.Palette.glassFill)
            Image(systemName: "music.note")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(DT.Palette.textTertiary)
        }
    }

    // MARK: - Recent rows (compact)

    private var recentRows: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Recent")
                    .font(DT.Typography.label)
                    .foregroundColor(DT.Palette.textTertiary)
                    .tracking(1.2)

                Spacer()

                Button(action: onOpenList) {
                    HStack(spacing: 3) {
                        Text("LIST")
                            .font(DT.Typography.label)
                            .tracking(1.2)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(DT.Palette.textSecondary)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DT.Spacing.md)
            .padding(.top, 10)
            .padding(.bottom, 6)

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
    }

    private var divider: some View {
        Rectangle()
            .fill(DT.Palette.glassBorder)
            .frame(height: 0.5)
    }
}

private struct CompactRecentRow: View {
    let event: ResonanceEvent

    var body: some View {
        HStack(spacing: DT.Spacing.sm) {
            VStack(alignment: .leading, spacing: 1) {
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
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(DT.Palette.accent)
                .frame(width: 24, height: 24)
                .background(Circle().fill(DT.Palette.glassFill))
                .overlay(Circle().strokeBorder(DT.Palette.glassBorder, lineWidth: 0.5))
        }
        .padding(.horizontal, DT.Spacing.md)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
