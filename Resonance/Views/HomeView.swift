import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var router: DeepLinkRouter
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                DT.Palette.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DT.Spacing.xl) {
                        header

                        NowPlayingCard(info: viewModel.nowPlaying, isActive: viewModel.isActive)

                        recentSection
                    }
                    .padding(.horizontal, DT.Spacing.lg)
                    .padding(.top, DT.Spacing.lg)
                    .padding(.bottom, DT.Spacing.xxl)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: FeedDestination.self) { destination in
                FeedView(
                    viewModel: FeedViewModel(
                        events: viewModel.recentResonances,
                        initialSelection: destination.eventID
                    ),
                    initialMode: .map
                )
            }
        }
        .tint(DT.Palette.accent)
        .onChange(of: router.pendingEventID) { newID in
            handleDeepLink(newID)
        }
        .onAppear {
            handleDeepLink(router.pendingEventID)
        }
    }

    private func handleDeepLink(_ id: UUID?) {
        guard let id, viewModel.recentResonances.contains(where: { $0.id == id }) else {
            return
        }
        if path.count > 0 {
            path.removeLast(path.count)
        }
        path.append(FeedDestination(eventID: id))
        DispatchQueue.main.async {
            router.pendingEventID = nil
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            StatusIndicator(status: viewModel.status)
            Spacer(minLength: DT.Spacing.md)
            actionButton
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        Button {
            withAnimation(DT.Motion.standard) {
                viewModel.toggle()
            }
        } label: {
            Text(viewModel.status.actionLabel)
                .font(DT.Typography.label)
                .foregroundColor(DT.Palette.textSecondary)
                .tracking(1.0)
                .padding(.horizontal, DT.Spacing.md)
                .padding(.vertical, DT.Spacing.sm)
                .background(Capsule().fill(DT.Palette.glassFill))
                .overlay(Capsule().strokeBorder(DT.Palette.glassBorder, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: DT.Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recent")
                    .font(DT.Typography.label)
                    .foregroundColor(DT.Palette.textTertiary)
                    .tracking(1.2)

                Spacer()

                NavigationLink(value: FeedDestination(eventID: viewModel.recentResonances.first?.id ?? UUID())) {
                    HStack(spacing: 4) {
                        Image(systemName: "map")
                            .font(.system(size: 11, weight: .semibold))
                        Text("MAP")
                            .font(DT.Typography.label)
                            .tracking(1.2)
                    }
                    .foregroundColor(DT.Palette.textSecondary)
                    .padding(.horizontal, DT.Spacing.md)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(DT.Palette.glassFill))
                    .overlay(Capsule().strokeBorder(DT.Palette.glassBorder, lineWidth: 1))
                    .contentShape(Capsule())
                }
            }

            if viewModel.recentResonances.isEmpty {
                Text("No resonance yet")
                    .font(DT.Typography.body)
                    .foregroundColor(DT.Palette.textTertiary)
                    .padding(.vertical, DT.Spacing.md)
            } else {
                VStack(spacing: 0) {
                    let visible = Array(viewModel.recentResonances.prefix(3))
                    ForEach(Array(visible.enumerated()), id: \.element.id) { index, event in
                        NavigationLink(value: FeedDestination(eventID: event.id)) {
                            ArchiveRow(event: event)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if index < visible.count - 1 {
                            rowSeparator
                        }
                    }
                }
            }
        }
    }

    private var rowSeparator: some View {
        Rectangle()
            .fill(DT.Palette.glassBorder)
            .frame(height: 0.5)
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
        .environmentObject(DeepLinkRouter.shared)
}
