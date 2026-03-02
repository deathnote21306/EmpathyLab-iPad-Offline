import SwiftUI

/*
 Neural Spellbook Architecture
 ----------------------------
 - App/AppState: global routing and shared view-model lifecycle.
 - ViewModels: GuidedJourney (chapter story orchestration), Sandbox (ML controls + live state), Diagnostics (issues + one-click fixes).
 - ML: pure-Swift tensor + MLP + optimizers + training engine for full offline explainability.
 - Views: Home -> Guided Journey (3-4 min story) or Free Play sandbox using shared Living Stage visuals.
 - DesignSystem: reusable premium UI primitives (glass cards, typography, particles, progress, toasts).
*/
@main
struct NeuralSpellbookApp: App {
    @StateObject private var appState = AppState()

    init() {
        AudioManager.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

private struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            switch appState.route {
            case .guided:
                SpellbookShellView(onExit: { appState.goHome() })
                .transition(.opacity)

            case .sandbox:
                SandboxView(
                    viewModel: appState.sandboxViewModel,
                    diagnosticsViewModel: appState.diagnosticsViewModel
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState.route)
        .sheet(isPresented: $appState.showHelp) {
            HelpAboutView()
        }
        .task { AudioManager.shared.start() }
    }
}
