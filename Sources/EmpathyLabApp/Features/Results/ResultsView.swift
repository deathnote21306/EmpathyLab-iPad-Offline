import SwiftUI

public struct ResultsView: View {
    public let onContinue: () -> Void
    public let onBackToHome: () -> Void

    public init(
        onContinue: @escaping () -> Void,
        onBackToHome: @escaping () -> Void
    ) {
        self.onContinue = onContinue
        self.onBackToHome = onBackToHome
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Results")
                .font(.largeTitle)
            Button("Continue", action: onContinue)
            Button("Back to Home", action: onBackToHome)
        }
        .padding()
    }
}
