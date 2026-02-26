import SwiftUI

public struct LabPayBillView: View {
    public let onFinish: () -> Void
    public let onBack: () -> Void

    public init(
        onFinish: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) {
        self.onFinish = onFinish
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Lab")
                .font(.largeTitle)
            Button("Finish", action: onFinish)
            Button("Back", action: onBack)
        }
        .padding()
    }
}

public typealias LabView = LabPayBillView
