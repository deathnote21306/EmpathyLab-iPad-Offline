import SwiftUI

public struct DebriefView: View {
    public let onDone: () -> Void

    public init(onDone: @escaping () -> Void) {
        self.onDone = onDone
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Debrief")
                .font(.largeTitle)
            Text("Review the key accessibility improvements.")
            Button("Done", action: onDone)
        }
        .padding()
    }
}
