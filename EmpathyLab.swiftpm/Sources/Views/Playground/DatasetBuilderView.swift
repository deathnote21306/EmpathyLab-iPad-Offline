import SwiftUI

struct DatasetBuilderView: View {
    @ObservedObject var viewModel: PlaygroundViewModel

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Dataset Builder", systemImage: "point.3.connected.trianglepath.dotted")
                    .font(Typography.section)

                Picker("Type", selection: $viewModel.datasetKind) {
                    ForEach(DatasetKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                LabeledSlider(title: "Points", value: $viewModel.numberOfPoints, range: 80...520, step: 10, formatter: { "\(Int($0))" })
                LabeledSlider(title: "Noise", value: $viewModel.noise, range: 0...0.6, step: 0.01)
                LabeledSlider(title: "Seed", value: $viewModel.seed, range: 1...999, step: 1, formatter: { "\(Int($0))" })

                Toggle("Normalize inputs", isOn: $viewModel.normalizeData)

                PrimaryActionButton(title: "Regenerate Dataset", systemImage: "arrow.triangle.2.circlepath") {
                    viewModel.regenerateDataset()
                }
            }
        }
    }
}
