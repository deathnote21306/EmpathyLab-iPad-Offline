import SwiftUI

// Architecture summary:
// - AppState owns shared ViewModels (Playground, Lessons, Diagnostics).
// - Views are split into Home, Guided Lessons, and Free Playground.
// - ML engine is pure Swift (Tensor + MLP + backprop) and fully offline.
// - The glass-box inspector surfaces activations, gradients, tensors, and diagnostics.
@main
struct NeuralLabApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NeuralLabRootView()
                .environmentObject(appState)
        }
    }
}

struct NeuralLabRootView: View {
    @EnvironmentObject private var appState: AppState

    @State private var showGuidedPath = false
    @State private var showPlayground = false

    var body: some View {
        NavigationStack {
            HomeView(
                onStartGuidedPath: {
                    appState.lessonFlowViewModel.applyCurrentSetup()
                    showGuidedPath = true
                },
                onOpenPlayground: {
                    showPlayground = true
                },
                onOpenHelp: {
                    appState.showHelp = true
                }
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset Everything") {
                        appState.playgroundViewModel.resetEverything()
                        appState.lessonFlowViewModel.applyCurrentSetup()
                    }
                }
            }
            .sheet(isPresented: $showGuidedPath) {
                LessonFlowView(
                    viewModel: appState.lessonFlowViewModel,
                    playgroundViewModel: appState.playgroundViewModel,
                    diagnosticsViewModel: appState.diagnosticsViewModel
                )
            }
            .sheet(isPresented: $showPlayground) {
                NavigationStack {
                    PlaygroundView(
                        viewModel: appState.playgroundViewModel,
                        diagnosticsViewModel: appState.diagnosticsViewModel
                    )
                }
            }
            .sheet(isPresented: $appState.showHelp) {
                HelpAboutView()
            }
        }
    }
}
