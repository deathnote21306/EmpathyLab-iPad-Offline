import SwiftUI

public struct SafetySheetView: View {
    public let onContinue: () -> Void
    public let onCancel: () -> Void

    public init(
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onContinue = onContinue
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Safety Check")
                .font(.title)
            Text("You can stop at any time.")
            Button("Continue", action: onContinue)
            Button("Cancel", action: onCancel)
        }
        .padding()
    }
}
