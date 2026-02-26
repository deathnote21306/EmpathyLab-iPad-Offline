import SwiftUI

public struct ResultsView: View {
    public let onTryFix: () -> Void
    public let onBackHome: () -> Void

    @StateObject private var metricsStore = MetricsStore.shared

    public init(
        onTryFix: @escaping () -> Void,
        onBackHome: @escaping () -> Void
    ) {
        self.onTryFix = onTryFix
        self.onBackHome = onBackHome
    }

    // Compatibility for older AppRootView wiring.
    public init(
        onContinue: @escaping () -> Void,
        onBackToHome: @escaping () -> Void
    ) {
        self.onTryFix = onContinue
        self.onBackHome = onBackToHome
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Results")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                BeforeAfterComparisonView(metrics: metricsStore.metrics)

                if metricsStore.metrics.fixTimeSeconds == nil {
                    Button("Try the Fix") {
                        onTryFix()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: 44)
                }

                Button("Back to Home") {
                    onBackHome()
                }
                .buttonStyle(.bordered)
                .frame(minHeight: 44)
            }
            .padding(24)
        }
    }
}
