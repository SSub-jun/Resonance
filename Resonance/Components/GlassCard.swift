import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = DT.Glass.cornerRadius
    var padding: CGFloat = DT.Spacing.lg
    var backgroundFill: Color? = nil
    var accentBorderColor: Color? = nil
    var accentBorderWidth: CGFloat = 1
    var glowColor: Color? = nil
    var glowRadius: CGFloat = 0
    @ViewBuilder var content: () -> Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    if let backgroundFill {
                        shape.fill(backgroundFill)
                    }
                    shape.fill(.ultraThinMaterial.opacity(0.35))
                    shape.fill(DT.Palette.glassFill)
                }
            }
            .overlay {
                shape.strokeBorder(DT.Palette.glassBorder, lineWidth: DT.Glass.borderWidth)
            }
            .overlay {
                if let accentBorderColor {
                    shape.strokeBorder(accentBorderColor, lineWidth: accentBorderWidth)
                }
            }
            .shadow(color: glowColor ?? .clear, radius: glowRadius, x: 0, y: 0)
    }
}
