import SwiftUI

public struct SelectionView: View {
    public let onContinueToLab: () -> Void
    public let onShowAbout: () -> Void

    public init(
        onContinueToLab: @escaping () -> Void,
        onShowAbout: @escaping () -> Void
    ) {
        self.onContinueToLab = onContinueToLab
        self.onShowAbout = onShowAbout
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Selection")
                .font(.largeTitle)
            Button("Continue to Lab", action: onContinueToLab)
            Button("About", action: onShowAbout)
        }
        .padding()
    }
}
