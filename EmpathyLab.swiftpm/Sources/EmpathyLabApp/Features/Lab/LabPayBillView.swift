import SwiftUI

public struct LabPayBillView: View {
    public let onFinishLab: () -> Void

    @StateObject private var metricsStore = MetricsStore.shared

    @State private var amountText = ""
    @State private var dueDate = Date()
    @State private var feedbackText = ""
    @State private var hasStarted = false

    public init(onFinishLab: @escaping () -> Void) {
        self.onFinishLab = onFinishLab
    }

    // Compatibility for older AppRootView wiring.
    public init(onFinish: @escaping () -> Void, onBack: @escaping () -> Void) {
        self.onFinishLab = onFinish
    }

    private var isAmountValid: Bool {
        let cleaned = amountText
            .replacingOccurrences(of: ",", with: ".")
            .filter { "0123456789.".contains($0) }
        guard let value = Double(cleaned), value > 0 else { return false }
        return true
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Pay a Bill (Lab)")
                    .font(.title2)
                    .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.38))

                Text("Try to complete the payment.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                AmountField(
                    title: "Amount",
                    placeholder: "0",
                    text: $amountText,
                    style: .lab
                )

                DatePickerRow(
                    title: "Date",
                    date: $dueDate,
                    style: .lab
                )

                ConfirmButtonRow(
                    title: "Confirm",
                    isEnabled: isAmountValid,
                    action: confirmTapped,
                    style: .lab
                )

                if !feedbackText.isEmpty {
                    Text(feedbackText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
            }
            .padding(12)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.96))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Stop") {
                    metricsStore.finishLab()
                    onFinishLab()
                }
                .foregroundStyle(.red)
            }
        }
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            metricsStore.startLab()
        }
    }

    private func confirmTapped() {
        guard isAmountValid else {
            metricsStore.registerLabError()
            feedbackText = "Not quite..."
            return
        }

        metricsStore.finishLab()
        feedbackText = "Submitted..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onFinishLab()
        }
    }
}

public typealias LabView = LabPayBillView
