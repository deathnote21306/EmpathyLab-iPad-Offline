import SwiftUI

public struct BeforeAfterComparisonView: View {
    public let metrics: RunMetrics

    public init(metrics: RunMetrics) {
        self.metrics = metrics
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Before vs After")
                .font(.title3)
                .fontWeight(.semibold)

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Before (Lab)")
                        .font(.headline)
                    MetricCard(
                        title: "Time",
                        value: RunMetrics.format(seconds: metrics.labTimeSeconds),
                        subtitle: "Completion"
                    )
                    MetricCard(
                        title: "Errors",
                        value: "\(metrics.labErrorCount)",
                        subtitle: "Input mistakes"
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("After (Fix)")
                        .font(.headline)
                    MetricCard(
                        title: "Time",
                        value: RunMetrics.format(seconds: metrics.fixTimeSeconds),
                        subtitle: "Completion",
                        trend: .down
                    )
                    MetricCard(
                        title: "Errors",
                        value: "\(metrics.fixErrorCount)",
                        subtitle: "Input mistakes",
                        trend: .down
                    )
                }
            }

            if let percent = metrics.timeImprovementPercent,
               let delta = metrics.timeDeltaSeconds,
               delta > 0 {
                Text("You were \(percent)% faster (\(delta)s saved).")
                    .font(.headline)
                    .foregroundStyle(.green)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if let percent = metrics.timeImprovementPercent,
                      percent <= 0 {
                Text("Try again to improve your completion time.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
