import SwiftUI

public struct HomeView: View {
    public let onStartExperience: () -> Void
    public let onShowAbout: () -> Void

    public init(
        onStartExperience: @escaping () -> Void,
        onShowAbout: @escaping () -> Void
    ) {
        self.onStartExperience = onStartExperience
        self.onShowAbout = onShowAbout
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Empathy Lab")
                .font(.largeTitle)
            Button("Start Experience", action: onStartExperience)
            Button("About", action: onShowAbout)
        }
        .padding()
    }
}
