import SwiftUI

struct ResonanceListView: View {
    @ObservedObject var viewModel: FeedViewModel
    var onSelect: ((ResonanceEvent) -> Void)? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.events.enumerated()), id: \.element.id) { index, event in
                    Button {
                        onSelect?(event)
                    } label: {
                        ArchiveRow(event: event)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < viewModel.events.count - 1 {
                        Rectangle()
                            .fill(DT.Palette.glassBorder)
                            .frame(height: 0.5)
                    }
                }
            }
            .padding(.horizontal, DT.Spacing.lg)
            .padding(.vertical, DT.Spacing.md)
        }
    }
}
