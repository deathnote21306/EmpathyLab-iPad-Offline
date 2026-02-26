import SwiftUI

public struct DesignFixPayBillView: View {
    public let onContinue: () -> Void
    public let onBack: () -> Void

    @StateObject private var metricsStore = MetricsStore.shared

    @State private var amountText = ""
    @State private var dueDate = Date()
    @State private var showSuccess = false
    @State private var validationMessage = ""
    @State private var hasStarted = false

    public init(
        onContinue: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) {
        self.onContinue = onContinue
        self.onBack = onBack
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
            VStack(alignment: .leading, spacing: 18) {
                Text("Pay a Bill (Fix)")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                Text("Enter your payment amount, choose a due date, then confirm.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                AmountField(
                    title: "Bill amount",
                    placeholder: "e.g. 120.00",
                    text: $amountText,
                    style: .fix
                )

                DatePickerRow(
                    title: "Due date",
                    date: $dueDate,
                    style: .fix
                )

                ConfirmButtonRow(
                    title: "Confirm payment",
                    isEnabled: isAmountValid,
                    action: confirmTapped,
                    style: .fix
                )

                if !validationMessage.isEmpty {
                    Text(validationMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                if showSuccess {
                    Label("Payment confirmed.", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(Color.green)
                        .padding(.top, 4)
                        .transition(.opacity)
                }
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") {
                    onBack()
                }
            }
        }
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            metricsStore.startFix()
        }
    }

    private func confirmTapped() {
        guard isAmountValid else {
            metricsStore.registerFixError()
            validationMessage = "Please enter a valid amount greater than zero."
            return
        }

        metricsStore.finishFix()
        validationMessage = ""

        withAnimation(.easeInOut(duration: 0.2)) {
            showSuccess = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            onContinue()
        }
    }
}

public typealias DesignFixView = DesignFixPayBillView
