import SwiftUI

struct NowPlayingCard: View {
    let info: NowPlayingInfoModel
    var isActive: Bool = true

    var body: some View {
        ZStack {
            if isActive {
                ResonanceRipple()
                    .padding(-4)
            }

            GlassCard(padding: DT.Spacing.lg) {
                HStack(alignment: .top, spacing: DT.Spacing.md) {
                    artwork

                    VStack(alignment: .leading, spacing: DT.Spacing.xs) {
                        Text("Now Playing")
                            .font(DT.Typography.label)
                            .foregroundColor(DT.Palette.textTertiary)
                            .tracking(1.2)

                        Text(info.rawTitle.isEmpty ? "Nothing is playing" : info.rawTitle)
                            .font(DT.Typography.titleLarge)
                            .foregroundColor(DT.Palette.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                            .padding(.top, 2)

                        Text(info.rawArtist.isEmpty ? "—" : info.rawArtist)
                            .font(DT.Typography.titleMedium)
                            .foregroundColor(DT.Palette.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var artwork: some View {
        Group {
            if let url = info.artworkURL {
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
        .frame(width: 68, height: 68)
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
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(DT.Palette.textTertiary)
        }
    }
}
