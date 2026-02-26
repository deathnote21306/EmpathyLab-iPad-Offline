import SwiftUI

struct DiagnosticsPanelView: View {
    @ObservedObject var diagnosticsViewModel: DiagnosticsViewModel
    @ObservedObject var playgroundViewModel: PlaygroundViewModel

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Diagnostics", systemImage: "stethoscope")
                    .font(Typography.section)

                if diagnosticsViewModel.issues.isEmpty {
                    Text("No major issues detected. Keep exploring!")
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(diagnosticsViewModel.issues) { issue in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(issue.title)
                                .font(.headline)
                            Text(issue.message)
                                .font(Typography.caption)
                                .foregroundStyle(.secondary)
                            Button(issue.fixButtonTitle) {
                                diagnosticsViewModel.applyFix(issue, to: playgroundViewModel)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .onAppear { diagnosticsViewModel.refresh(using: playgroundViewModel) }
        .onChange(of: playgroundViewModel.currentStep) { diagnosticsViewModel.refresh(using: playgroundViewModel) }
        .onChange(of: playgroundViewModel.learningRate) { diagnosticsViewModel.refresh(using: playgroundViewModel) }
        .onChange(of: playgroundViewModel.batchSize) { diagnosticsViewModel.refresh(using: playgroundViewModel) }
        .onChange(of: playgroundViewModel.normalizeData) { diagnosticsViewModel.refresh(using: playgroundViewModel) }
        .onChange(of: playgroundViewModel.outputMode) { diagnosticsViewModel.refresh(using: playgroundViewModel) }
        .onChange(of: playgroundViewModel.dropout) { diagnosticsViewModel.refresh(using: playgroundViewModel) }
    }
}
