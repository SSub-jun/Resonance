import SwiftUI
import MapKit

struct ResonanceMapView: View {
    @ObservedObject var viewModel: FeedViewModel
    var showsDetailCard: Bool = true

    var body: some View {
        ZStack(alignment: .bottom) {
            mapLayer
                .ignoresSafeArea(edges: .bottom)
                .overlay(mapOverlay)
                .onTapGesture {
                    viewModel.clearSelection()
                }

            if showsDetailCard, let event = viewModel.selectedEvent {
                ResonanceDetailCard(event: event)
                    .padding(.horizontal, DT.Spacing.lg)
                    .padding(.bottom, DT.Spacing.lg)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(DT.Motion.standard, value: viewModel.selectedEventID)
    }

    private var mapLayer: some View {
        Map(
            coordinateRegion: $viewModel.region,
            annotationItems: viewModel.plottableEvents
        ) { event in
            MapAnnotation(coordinate: event.coordinate ?? .init(latitude: 0, longitude: 0)) {
                Button {
                    withAnimation(DT.Motion.standard) {
                        viewModel.select(event)
                    }
                } label: {
                    ResonancePinView(
                        type: event.type,
                        isSelected: viewModel.selectedEventID == event.id
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var mapOverlay: some View {
        LinearGradient(
            colors: [
                DT.Palette.background.opacity(0.55),
                .clear,
                .clear,
                DT.Palette.background.opacity(0.55)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }
}
