import Foundation
import SwiftUI

@MainActor
public final class AppState: ObservableObject {
    @Published public var showHelp = false

    public let playgroundViewModel: PlaygroundViewModel
    public let diagnosticsViewModel: DiagnosticsViewModel
    public let lessonFlowViewModel: LessonFlowViewModel

    public init() {
        let playground = PlaygroundViewModel()
        self.playgroundViewModel = playground
        self.diagnosticsViewModel = DiagnosticsViewModel()
        self.lessonFlowViewModel = LessonFlowViewModel(playground: playground)
    }

    public func refreshDiagnostics() {
        diagnosticsViewModel.refresh(using: playgroundViewModel)
    }
}
