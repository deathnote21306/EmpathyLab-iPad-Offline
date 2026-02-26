import SwiftUI

public struct AboutView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            Text("About")
                .font(.largeTitle)
            Text("This is an offline learning app prototype.")
            Button("Done") {}
        }
        .padding()
    }
}
