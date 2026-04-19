import SwiftUI

struct HomeBottomPanel: View {
    let nowPlaying: NowPlayingInfoModel
    let isActive: Bool
    let recent: [ResonanceEvent]
    var onSelectEvent: (ResonanceEvent) -> Void
    var onOpenList: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            nowPlayingSection

            if !recent.isEmpty {
                divider
                recentSection
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(DT.Palette.background.opacity(0.78))
        )
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(DT.Palette.glassBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Now Playing

    private var nowPlayingSection: some View {
        ZStack {
            if isActive {
                ResonanceRipple(cornerRadius: 18)
                    .padding(.horizontal, -4)
                    .padding(.vertical, -4)
                    .allowsHitTesting(false)
            }

            HStack(alignment: .center, spacing: DT.Spacing.md) {
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
                        .font(DT.Typography.body)
                        .foregroundColor(DT.Palette.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(DT.Spacing.md)
        }
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
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(DT.Palette.glassBorder, lineWidth: 0.5)
        )
    }

    private var artworkPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DT.Palette.glassFill)
            Image(systemName: "music.note")
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(DT.Palette.textTertiary)
        }
    }

    // MARK: - Recent

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: DT.Spacing.sm) {
            HStack(alignment: .firstTextBaseline) {
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
                    .padding(.horizontal, DT.Spacing.sm)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 0) {
                let visible = Array(recent.prefix(2))
                ForEach(Array(visible.enumerated()), id: \.element.id) { index, event in
                    Button {
                        onSelectEvent(event)
                    } label: {
                        ArchiveRow(event: event)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < visible.count - 1 {
                        Rectangle()
                            .fill(DT.Palette.glassBorder)
                            .frame(height: 0.5)
                    }
                }
            }
        }
        .padding(.horizontal, DT.Spacing.md)
        .padding(.top, DT.Spacing.md)
        .padding(.bottom, DT.Spacing.md)
    }

    private var divider: some View {
        Rectangle()
            .fill(DT.Palette.glassBorder)
            .frame(height: 0.5)
            .padding(.horizontal, DT.Spacing.md)
    }
}
