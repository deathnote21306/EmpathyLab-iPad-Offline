import Foundation
import SwiftUI

@MainActor
public final class AppState: ObservableObject {
    public enum Route {
        case guided
        case sandbox
    }

    @Published public var route: Route = .guided
    @Published public var showHelp: Bool = false
    @Published public var showSettings: Bool = false

    public let sandboxViewModel: SandboxViewModel
    public let guidedJourneyViewModel: GuidedJourneyViewModel
    public let diagnosticsViewModel: DiagnosticsViewModel

    public init() {
        let sandbox = SandboxViewModel()
        self.sandboxViewModel = sandbox
        self.guidedJourneyViewModel = GuidedJourneyViewModel(sandbox: sandbox)
        self.diagnosticsViewModel = DiagnosticsViewModel()
    }

    public func startGuidedJourney() {
        guidedJourneyViewModel.resetJourney()
        sandboxViewModel.showRuneNumbers = false
        sandboxViewModel.revealMathematicalForm = false
        route = .guided
    }

    public func enterFreePlay() {
        route = .sandbox
    }

    public func replayGuidedJourney() {
        startGuidedJourney()
    }

    public func goHome() {
        startGuidedJourney()
    }
}
