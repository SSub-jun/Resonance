import SwiftUI

struct ResonanceRipple: View {
    var color: Color = DT.Palette.accent
    var cornerRadius: CGFloat = DT.Glass.cornerRadius
    var ringCount: Int = 3
    var duration: Double = 3.2
    var maxScale: CGFloat = 1.16
    var baseOpacity: Double = 0.48
    var lineWidth: CGFloat = 1.4

    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<ringCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        color.opacity(animate ? 0.0 : baseOpacity),
                        lineWidth: lineWidth
                    )
                    .scaleEffect(animate ? maxScale : 1.0)
                    .animation(
                        .easeOut(duration: duration)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * (duration / Double(ringCount))),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
        .onDisappear { animate = false }
        .allowsHitTesting(false)
    }
}
