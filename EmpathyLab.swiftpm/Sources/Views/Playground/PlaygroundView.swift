import SwiftUI

struct PlaygroundView: View {
    @ObservedObject var viewModel: PlaygroundViewModel
    @ObservedObject var diagnosticsViewModel: DiagnosticsViewModel

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            GeometryReader { proxy in
                let isWide = proxy.size.width > 1000

                if isWide {
                    HStack(alignment: .top, spacing: 16) {
                        controlsColumn.frame(width: 360)
                        visualsColumn.frame(maxWidth: .infinity)
                    }
                    .padding(20)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            controlsColumn
                            visualsColumn
                        }
                        .padding(20)
                    }
                }
            }
        }
        .navigationTitle("Playground")
        .sheet(isPresented: $viewModel.showTensorInspector) {
            if let tensor = viewModel.selectedTensor {
                TensorInspectorView(tensor: tensor)
            }
        }
    }

    private var controlsColumn: some View {
        VStack(spacing: 12) {
            DatasetBuilderView(viewModel: viewModel)
            ModelBuilderView(viewModel: viewModel)
            TrainingView(viewModel: viewModel)
            DiagnosticsPanelView(diagnosticsViewModel: diagnosticsViewModel, playgroundViewModel: viewModel)
        }
    }

    private var visualsColumn: some View {
        VStack(spacing: 12) {
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Decision Boundary", systemImage: "chart.xyaxis.line")
                        .font(Typography.section)

                    ZStack {
                        DecisionBoundaryCanvas(values: viewModel.decisionBoundary, resolution: viewModel.boundaryResolution)
                        ScatterPlotView(points: viewModel.dataset.points)
                    }
                    .frame(height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            LayerInspectorView(inspections: viewModel.layerInspections)

            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Pause & Inspect", systemImage: "scope")
                        .font(Typography.section)

                    if viewModel.tensorSummaries.isEmpty {
                        Text("Run one training step to inspect tensors.")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.tensorSummaries) { tensor in
                            Button {
                                viewModel.selectedTensor = tensor
                                viewModel.showTensorInspector = true
                            } label: {
                                HStack {
                                    Text(tensor.name)
                                    Spacer()
                                    Text(tensor.shape.map(String.init).joined(separator: "×"))
                                        .font(Typography.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }
}
