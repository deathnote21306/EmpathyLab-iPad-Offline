import SwiftUI

struct LessonFlowView: View {
    @ObservedObject var viewModel: LessonFlowViewModel
    @ObservedObject var playgroundViewModel: PlaygroundViewModel
    @ObservedObject var diagnosticsViewModel: DiagnosticsViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                GeometryReader { proxy in
                    let isWide = proxy.size.width > 1000
                    if isWide {
                        HStack(alignment: .top, spacing: 16) {
                            ScrollView {
                                leftColumn
                            }
                            .frame(width: 370)
                            PlaygroundView(viewModel: playgroundViewModel, diagnosticsViewModel: diagnosticsViewModel)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(20)
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                leftColumn
                                PlaygroundView(viewModel: playgroundViewModel, diagnosticsViewModel: diagnosticsViewModel)
                            }
                            .padding(20)
                        }
                    }
                }
            }
            .navigationTitle("Guided Path")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var leftColumn: some View {
        VStack(spacing: 12) {
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Chapter Start", systemImage: "play.circle.fill")
                        .font(Typography.section)
                        .foregroundStyle(Theme.accent)

                    Text("Read the goal, then tap Start Chapter to load this lesson setup and begin.")
                        .font(Typography.body)
                        .foregroundStyle(.secondary)

                    PrimaryActionButton(
                        title: viewModel.isCurrentLessonComplete ? "Restart Chapter" : "Start Chapter",
                        systemImage: "play.fill"
                    ) {
                        viewModel.applyCurrentSetup()
                    }
                }
            }

            LessonView(
                lesson: viewModel.currentLesson,
                progressText: viewModel.progressText,
                isComplete: viewModel.isCurrentLessonComplete
            )

            LessonQuizView(
                question: viewModel.currentLesson.quickQuestion,
                choices: viewModel.currentLesson.quickChoices,
                selectedChoice: $viewModel.selectedChoice,
                didSubmit: viewModel.didSubmitQuiz,
                feedback: viewModel.quizFeedback,
                onSubmit: viewModel.submitQuiz
            )

            HStack(spacing: 8) {
                Button("Previous") { viewModel.previousLesson() }
                    .buttonStyle(.bordered)
                Button("Next") { viewModel.nextLesson() }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.isCurrentLessonComplete)
            }
        }
    }
}
