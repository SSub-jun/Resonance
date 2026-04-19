import SwiftUI

struct HomeTopOverlay: View {
    let nowPlaying: NowPlayingInfoModel
    let actionLabel: String
    let isActive: Bool
    var onAction: () -> Void

    var body: some View {
        ZStack {
            if isActive {
                ResonanceRipple(
                    cornerRadius: 22,
                    startScale: 0.82,
                    endScale: 1.0,
                    baseOpacity: 0.55
                )
                .allowsHitTesting(false)
            }

            HStack(alignment: .center, spacing: DT.Spacing.md) {
                HStack(alignment: .center, spacing: DT.Spacing.sm) {
                    artwork

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Now Playing")
                            .font(DT.Typography.label)
                            .foregroundColor(DT.Palette.textTertiary)
                            .tracking(1.0)

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

                actionButton
            }
            .padding(DT.Spacing.md)
            .background(panelBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(DT.Palette.glassBorder, lineWidth: 1)
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Subviews

    private var panelBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(DT.Palette.background.opacity(0.78))
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.55))
        }
    }

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
        .frame(width: 44, height: 44)
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
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(DT.Palette.textTertiary)
        }
    }
}
