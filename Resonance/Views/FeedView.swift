import SwiftUI

struct FeedView: View {
    @StateObject var viewModel: FeedViewModel
    @State private var mode: FeedMode

    init(viewModel: FeedViewModel, initialMode: FeedMode = .map) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _mode = State(initialValue: initialMode)
    }

    var body: some View {
        ZStack {
            DT.Palette.background.ignoresSafeArea()

            Group {
                switch mode {
                case .map:
                    ResonanceMapView(viewModel: viewModel)
                case .list:
                    ResonanceListView(viewModel: viewModel, onSelect: handleListSelect)
                }
            }
            .transition(.opacity)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DT.Palette.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                FeedToggle(selection: $mode)
            }
        }
    }

    private func handleListSelect(_ event: ResonanceEvent) {
        viewModel.select(event)
        withAnimation(DT.Motion.standard) {
            mode = .map
        }
    }
}
