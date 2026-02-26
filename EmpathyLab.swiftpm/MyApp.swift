import SwiftUI

// Legacy fallback type kept for compatibility with older playground metadata.
// NeuralLabApp is the single @main entry point.
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NeuralLabRootView()
        }
    }
}
