import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var feedVM = FeedViewModel(events: ResonanceEvent.sampleList)
    @EnvironmentObject private var router: DeepLinkRouter
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                ResonanceMapView(viewModel: feedVM, showsDetailCard: false)
                    .ignoresSafeArea()

                topOverlay
            }
            .overlay(alignment: .bottom) { bottomOverlay }
            .animation(DT.Motion.standard, value: feedVM.selectedEventID)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ListDestination.self) { _ in
                ResonanceListView(viewModel: feedVM, onSelect: handleListSelection)
                    .toolbarBackground(DT.Palette.background, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationTitle("Resonance")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .tint(DT.Palette.accent)
        .onAppear { handleDeepLink(router.pendingEventID) }
        .onChange(of: router.pendingEventID) { handleDeepLink($0) }
    }

    private var topOverlay: some View {
        HomeTopOverlay(
            nowPlaying: viewModel.nowPlaying,
            actionLabel: viewModel.status.actionLabel,
            isActive: viewModel.isActive
        ) {
            withAnimation(DT.Motion.standard) { viewModel.toggle() }
        }
        .padding(.horizontal, DT.Spacing.md)
        .padding(.top, DT.Spacing.sm)
    }

    private var bottomOverlay: some View {
        HomeBottomPanel(
            selectedEvent: feedVM.selectedEvent,
            recent: viewModel.recentResonances,
            onSelectEvent: { event in
                withAnimation(DT.Motion.standard) { feedVM.select(event) }
            },
            onOpenList: {
                path.append(ListDestination())
            }
        )
        .padding(.horizontal, DT.Spacing.md)
        .padding(.bottom, DT.Spacing.md)
    }

    private func handleDeepLink(_ id: UUID?) {
        guard let id,
              let event = viewModel.recentResonances.first(where: { $0.id == id }) else {
            return
        }
        if path.count > 0 { path.removeLast(path.count) }
        withAnimation(DT.Motion.standard) { feedVM.select(event) }
        DispatchQueue.main.async { router.pendingEventID = nil }
    }

    private func handleListSelection(_ event: ResonanceEvent) {
        withAnimation(DT.Motion.standard) { feedVM.select(event) }
        if path.count > 0 { path.removeLast(path.count) }
    }
}

struct ListDestination: Hashable {}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
        .environmentObject(DeepLinkRouter.shared)
}
