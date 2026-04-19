import SwiftUI
import UIKit

@main
struct ResonanceApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        configureNavigationBarAppearance()
        NotificationHandler.shared.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
                .environmentObject(DeepLinkRouter.shared)
                .onAppear {
                    forceDarkAppearance()
                    NotificationHandler.shared.requestPermission()
                }
        }
        .onChange(of: scenePhase) { _ in
            forceDarkAppearance()
        }
    }

    private func forceDarkAppearance() {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        windows.forEach { $0.overrideUserInterfaceStyle = .dark }
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(DT.Palette.background)
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.92)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(DT.Palette.textPrimary)
    }
}
