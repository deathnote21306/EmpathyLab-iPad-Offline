import SwiftUI

public struct DesignFixPayBillView: View {
    public let onContinue: () -> Void
    public let onBack: () -> Void

    public init(
        onContinue: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) {
        self.onContinue = onContinue
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Design Fix")
                .font(.largeTitle)
            Button("Continue", action: onContinue)
            Button("Back", action: onBack)
        }
        .padding()
    }
}

public typealias DesignFixView = DesignFixPayBillView
