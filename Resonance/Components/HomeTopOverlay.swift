import SwiftUI

struct HomeTopOverlay: View {
    let nowPlaying: NowPlayingInfoModel
    let artworkImage: UIImage?
    let actionLabel: String
    let isActive: Bool
    var onAction: () -> Void

    private var hasMedia: Bool {
        !nowPlaying.rawTitle.isEmpty || !nowPlaying.rawArtist.isEmpty
    }

    private var showsRipple: Bool {
        isActive && hasMedia
    }

    var body: some View {
        cardContent
            .padding(DT.Spacing.md)
            .background(background)
            .overlay(border)
    }

    // MARK: - Card content

    private var cardContent: some View {
        HStack(alignment: .center, spacing: DT.Spacing.md) {
            HStack(alignment: .center, spacing: DT.Spacing.sm) {
                artwork

                VStack(alignment: .leading, spacing: 2) {
                    Text(hasMedia ? "Now Playing" : "Standby")
                        .font(DT.Typography.label)
                        .foregroundColor(DT.Palette.textTertiary)
                        .tracking(1.0)

                    Text(hasMedia ? nowPlaying.rawTitle : "No music detected")
                        .font(DT.Typography.titleMedium)
                        .foregroundColor(hasMedia ? DT.Palette.textPrimary : DT.Palette.textSecondary)
                        .lineLimit(1)

                    Text(hasMedia ? nowPlaying.rawArtist : "Play something to resonate")
                        .font(DT.Typography.caption)
                        .foregroundColor(DT.Palette.textTertiary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            actionButton
        }
    }

    // MARK: - Background (panel + ripple extending outward)

    private var background: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(DT.Palette.background.opacity(0.78))
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.55))
            if showsRipple {
                ResonanceRipple(
                    cornerRadius: 22,
                    startScale: 1.0,
                    endScale: 1.18,
                    baseOpacity: 0.55
                )
            }
        }
    }

    private var border: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .strokeBorder(DT.Palette.glassBorder, lineWidth: 1)
    }

    // MARK: - Action button

    private var actionButton: some View {
        Button(action: onAction) {
            Text(actionLabel)
                .font(DT.Typography.label)
                .foregroundColor(DT.Palette.textSecondary)
                .tracking(1.0)
                .padding(.horizontal, DT.Spacing.md)
                .padding(.vertical, 10)
                .background(Capsule().fill(DT.Palette.glassFill))
                .overlay(Capsule().strokeBorder(DT.Palette.glassBorder, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Artwork

    private var artwork: some View {
        Group {
            if let image = artworkImage {
                Image(uiImage: image).resizable().scaledToFill()
            } else if hasMedia, let url = nowPlaying.artworkURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        artworkPlaceholder(muted: false)
                    }
                }
            } else {
                artworkPlaceholder(muted: !hasMedia)
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(DT.Palette.glassBorder, lineWidth: 0.5)
        )
    }

    private func artworkPlaceholder(muted: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(DT.Palette.glassFill)
            Image(systemName: muted ? "waveform.slash" : "music.note")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(DT.Palette.textTertiary)
        }
    }
}
