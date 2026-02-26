import SwiftUI

struct TrainingView: View {
    @ObservedObject var viewModel: PlaygroundViewModel

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Training", systemImage: "waveform.path.ecg")
                    .font(Typography.section)

                HStack(spacing: 8) {
                    ChoiceChip(title: "Step", isSelected: false) {
                        viewModel.stepTraining()
                    }
                    ChoiceChip(title: viewModel.isPlaying ? "Pause" : "Play", isSelected: viewModel.isPlaying) {
                        viewModel.togglePlayPause()
                    }
                    ChoiceChip(title: "Reset", isSelected: false) {
                        viewModel.resetTraining(keepDataset: true)
                    }
                }

                LabeledSlider(title: "Learning rate", value: $viewModel.learningRate, range: 0.001...0.3, step: 0.001)
                LabeledSlider(title: "Batch size", value: $viewModel.batchSize, range: 4...64, step: 1, formatter: { "\(Int($0))" })
                Toggle("Early stopping", isOn: $viewModel.earlyStoppingEnabled)

                HStack(spacing: 16) {
                    metric(label: "Step", value: "\(viewModel.currentStep)")
                    metric(label: "Train Acc", value: percent(viewModel.trainAccuracy))
                    metric(label: "Val Acc", value: percent(viewModel.validationAccuracy))
                }

                Text("Loss")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                LossChartView(points: viewModel.lossHistory)
                    .frame(height: 130)

                if let first = viewModel.phaseMessages.first {
                    Text(first)
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func metric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(Typography.section)
        }
    }

    private func percent(_ value: Float) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}
