import SwiftUI

public struct DesignFixPayBillView: View {
    public let onContinue: () -> Void
    public let onBack: () -> Void

    @State private var amountText = ""
    @State private var dueDate = Date()
    @State private var showSuccess = false

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
    }

    private func confirmTapped() {
        guard isAmountValid else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            showSuccess = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            onContinue()
        }
    }
}

public typealias DesignFixView = DesignFixPayBillView
