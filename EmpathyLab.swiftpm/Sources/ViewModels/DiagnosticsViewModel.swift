import Foundation
import SwiftUI

@MainActor
public final class DiagnosticsViewModel: ObservableObject {
    @Published public var issues: [DiagnosticIssue] = []

    public init() {}

    public func refresh(using vm: PlaygroundViewModel) {
        var found: [DiagnosticIssue] = []
        let losses = vm.lossHistory.map(\.loss)

        if vm.learningRate > 0.12,
           losses.count > 8,
           let last = losses.last,
           let earlier = losses.dropLast(5).last,
           last > earlier * 1.2 {
            found.append(
                DiagnosticIssue(
                    severity: .high,
                    title: "Learning rate seems too high",
                    message: "Loss is rising quickly. The optimizer might be overshooting.",
                    fixButtonTitle: "Reduce LR + clip gradients",
                    fix: .reduceLearningRate
                )
            )
        }

        if vm.learningRate < 0.004,
           losses.count > 12,
           let first = losses.first,
           let last = losses.last,
           abs(last - first) < 0.05 {
            found.append(
                DiagnosticIssue(
                    severity: .medium,
                    title: "Learning rate may be too low",
                    message: "Loss barely changes over time.",
                    fixButtonTitle: "Increase LR",
                    fix: .increaseLearningRate
                )
            )
        }

        if vm.batchSize < 8 {
            found.append(
                DiagnosticIssue(
                    severity: .medium,
                    title: "Batch size is very small",
                    message: "Training may look noisy and unstable.",
                    fixButtonTitle: "Increase batch size",
                    fix: .increaseBatchSize
                )
            )
        }

        if !vm.normalizeData {
            found.append(
                DiagnosticIssue(
                    severity: .high,
                    title: "Data is not normalized",
                    message: "Different scales can slow down training.",
                    fixButtonTitle: "Normalize dataset",
                    fix: .normalizeDataset
                )
            )
        }

        if vm.outputMode == .softmax {
            found.append(
                DiagnosticIssue(
                    severity: .low,
                    title: "Output mismatch for binary task",
                    message: "Sigmoid is usually simpler for two classes.",
                    fixButtonTitle: "Switch to sigmoid",
                    fix: .switchToSigmoidOutput
                )
            )
        }

        if vm.lossHistory.count > 20,
           vm.trainAccuracy - vm.validationAccuracy > 0.12 {
            found.append(
                DiagnosticIssue(
                    severity: .medium,
                    title: "Possible overfitting",
                    message: "Train accuracy keeps improving while validation lags.",
                    fixButtonTitle: "Add dropout + early stop",
                    fix: .addDropout
                )
            )
        }

        issues = Array(found.sorted(by: { $0.severity < $1.severity }).prefix(3))
    }

    public func applyFix(_ issue: DiagnosticIssue, to vm: PlaygroundViewModel) {
        switch issue.fix {
        case .reduceLearningRate:
            vm.learningRate = max(0.001, vm.learningRate * 0.5)
            vm.gradientClip = max(vm.gradientClip, 1.0)
            vm.rebuildModel()
        case .increaseLearningRate:
            vm.learningRate = min(0.25, vm.learningRate * 1.8)
            vm.rebuildModel()
        case .increaseBatchSize:
            vm.batchSize = min(64, max(8, vm.batchSize * 2))
        case .normalizeDataset:
            vm.normalizeDatasetNow()
            vm.rebuildModel()
        case .switchToSigmoidOutput:
            vm.outputMode = .sigmoid
            vm.rebuildModel()
        case .addDropout:
            vm.dropout = max(0.2, vm.dropout)
            vm.earlyStoppingEnabled = true
            vm.rebuildModel()
        case .enableEarlyStopping:
            vm.earlyStoppingEnabled = true
        case .addL2:
            vm.l2 = max(0.001, vm.l2)
            vm.rebuildModel()
        case .enableGradientClip:
            vm.gradientClip = max(1, vm.gradientClip)
            vm.rebuildModel()
        }

        refresh(using: vm)
    }
}
