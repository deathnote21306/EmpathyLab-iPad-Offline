import SwiftUI

struct ModelBuilderView: View {
    @ObservedObject var viewModel: PlaygroundViewModel

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Model Builder", systemImage: "square.stack.3d.up")
                    .font(Typography.section)

                Picker("Hidden layers", selection: $viewModel.hiddenLayerCount) {
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("3").tag(3)
                }
                .pickerStyle(.segmented)

                LabeledSlider(title: "Layer 1 width", value: $viewModel.hiddenLayer1, range: 2...64, step: 1, formatter: { "\(Int($0))" })

                if viewModel.hiddenLayerCount >= 2 {
                    LabeledSlider(title: "Layer 2 width", value: $viewModel.hiddenLayer2, range: 2...64, step: 1, formatter: { "\(Int($0))" })
                }

                if viewModel.hiddenLayerCount >= 3 {
                    LabeledSlider(title: "Layer 3 width", value: $viewModel.hiddenLayer3, range: 2...64, step: 1, formatter: { "\(Int($0))" })
                }

                Picker("Activation", selection: $viewModel.activation) {
                    ForEach(ActivationKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Output", selection: $viewModel.outputMode) {
                    ForEach(OutputMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                LabeledSlider(title: "Dropout", value: $viewModel.dropout, range: 0...0.5, step: 0.01)
                LabeledSlider(title: "L2", value: $viewModel.l2, range: 0...0.01, step: 0.0005)
                LabeledSlider(title: "Gradient clip", value: $viewModel.gradientClip, range: 0...3, step: 0.1)

                Picker("Optimizer", selection: $viewModel.optimizerType) {
                    ForEach(OptimizerType.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                PrimaryActionButton(title: "Rebuild Model", systemImage: "hammer") {
                    viewModel.rebuildModel()
                }
            }
        }
    }
}
