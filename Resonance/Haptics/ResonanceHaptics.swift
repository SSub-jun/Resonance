import Foundation
import CoreHaptics
import UIKit

final class ResonanceHaptics {
    static let shared = ResonanceHaptics()

    private var engine: CHHapticEngine?
    private let supportsHaptics: Bool

    private init() {
        self.supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        prepare()
    }

    private func prepare() {
        guard supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.isAutoShutdownEnabled = true
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            engine?.stoppedHandler = { _ in }
            try engine?.start()
        } catch {
            engine = nil
        }
    }

    func playResonance(type: ResonanceType) {
        guard supportsHaptics, let engine else {
            fallback(for: type)
            return
        }

        let startIntensity: Float = type == .sameSong ? 1.0 : 0.6
        let duration: TimeInterval = type == .sameSong ? 1.3 : 1.0

        do {
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: startIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0,
                duration: duration
            )

            let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0.0, value: Float(startIntensity)),
                    .init(relativeTime: duration * 0.3, value: Float(startIntensity * 0.55)),
                    .init(relativeTime: duration * 0.65, value: 0.25),
                    .init(relativeTime: duration, value: 0.05)
                ],
                relativeTime: 0
            )

            let sharpnessCurve = CHHapticParameterCurve(
                parameterID: .hapticSharpnessControl,
                controlPoints: [
                    .init(relativeTime: 0.0, value: 0.5),
                    .init(relativeTime: duration, value: 0.2)
                ],
                relativeTime: 0
            )

            let pattern = try CHHapticPattern(
                events: [event],
                parameterCurves: [intensityCurve, sharpnessCurve]
            )
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            fallback(for: type)
        }
    }

    private func fallback(for type: ResonanceType) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle = type == .sameSong ? .medium : .soft
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
