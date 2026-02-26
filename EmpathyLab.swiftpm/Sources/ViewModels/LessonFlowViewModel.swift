import Foundation
import SwiftUI

@MainActor
public final class LessonFlowViewModel: ObservableObject {
    @Published public private(set) var lessons: [Lesson] = LessonFlowViewModel.defaultLessons
    @Published public var currentIndex: Int = 0
    @Published public var selectedChoice: Int?
    @Published public var didSubmitQuiz = false
    @Published public var quizFeedback = ""

    private unowned let playground: PlaygroundViewModel

    public init(playground: PlaygroundViewModel) {
        self.playground = playground
        applyCurrentSetup()
    }

    public var currentLesson: Lesson {
        lessons[currentIndex]
    }

    public var progressText: String {
        "Lesson \(currentIndex + 1) of \(lessons.count)"
    }

    public var isCurrentLessonComplete: Bool {
        switch currentLesson.completionRule {
        case .minimumSteps(let s):
            return playground.currentStep >= s
        case .validationAccuracy(let target):
            return playground.validationAccuracy >= target
        case .hiddenLayersAtLeast(let count):
            return playground.hiddenLayerCount >= count
        case .dropoutAtLeast(let value):
            return playground.dropout >= Double(value)
        case .l2AtLeast(let value):
            return playground.l2 >= Double(value)
        case .activationIs(let name):
            return playground.activation.rawValue.lowercased() == name.lowercased()
        }
    }

    public func applyCurrentSetup() {
        selectedChoice = nil
        didSubmitQuiz = false
        quizFeedback = ""
        playground.applyLessonSetup(currentLesson.setup)
    }

    public func submitQuiz() {
        guard let selectedChoice else { return }
        didSubmitQuiz = true
        if selectedChoice == currentLesson.correctChoiceIndex {
            quizFeedback = "Nice! You captured the key idea."
        } else {
            quizFeedback = "Good try. Re-run a few steps and compare the charts."
        }
    }

    public func nextLesson() {
        if currentIndex < lessons.count - 1 {
            currentIndex += 1
            applyCurrentSetup()
        }
    }

    public func previousLesson() {
        if currentIndex > 0 {
            currentIndex -= 1
            applyCurrentSetup()
        }
    }

    private static var defaultLessons: [Lesson] {
        [
            Lesson(
                title: "Make It Separable",
                goal: "See how noise bends the boundary.",
                narrative: "Start simple. Lower noise and watch the decision line become cleaner.",
                prompts: ["Move the noise slider.", "Train for 10–20 steps.", "Observe boundary smoothness."],
                setup: .lineSeparable,
                completionRule: .minimumSteps(12),
                quickQuestion: "What changed first when noise went down?",
                quickChoices: ["Boundary became cleaner", "Loss exploded", "Nothing changed"],
                correctChoiceIndex: 0
            ),
            Lesson(
                title: "XOR Needs a Hidden Layer",
                goal: "See why one straight boundary is not enough.",
                narrative: "XOR is the classic non-linear puzzle.",
                prompts: ["Set dataset to XOR.", "Try 0 hidden layers mentally.", "Train with at least 1 hidden layer."],
                setup: .xorNeedsHiddenLayer,
                completionRule: .hiddenLayersAtLeast(1),
                quickQuestion: "Why does XOR need a hidden layer?",
                quickChoices: ["To combine non-linear features", "To reduce batch size", "To avoid labels"],
                correctChoiceIndex: 0
            ),
            Lesson(
                title: "Learning Rate Feels Like...",
                goal: "Experience too high vs too low LR.",
                narrative: "Learning rate controls step size in weight space.",
                prompts: ["Try LR too high.", "Then lower it and compare loss trend."],
                setup: .learningRateStory,
                completionRule: .minimumSteps(18),
                quickQuestion: "Too high LR usually causes...",
                quickChoices: ["Jumping/unstable loss", "Perfect convergence", "No updates"],
                correctChoiceIndex: 0
            ),
            Lesson(
                title: "Overfitting",
                goal: "Spot train/val gap.",
                narrative: "A model can memorize training points but fail on new ones.",
                prompts: ["Train for a while.", "Watch train vs validation accuracy.", "Apply dropout."],
                setup: .overfittingStory,
                completionRule: .dropoutAtLeast(0.2),
                quickQuestion: "What helps reduce overfitting?",
                quickChoices: ["Dropout and regularization", "Bigger noise only", "Fewer labels"],
                correctChoiceIndex: 0
            ),
            Lesson(
                title: "Activation Choice",
                goal: "Compare ReLU and tanh behavior.",
                narrative: "Different activations shape gradients differently.",
                prompts: ["Train with ReLU.", "Switch to tanh.", "Compare convergence smoothness."],
                setup: .activationChoice,
                completionRule: .activationIs("tanh"),
                quickQuestion: "Changing activation mainly changes...",
                quickChoices: ["Feature transform and gradients", "Dataset labels", "Validation split"],
                correctChoiceIndex: 0
            ),
            Lesson(
                title: "Regularization",
                goal: "Use L2 to stabilize training.",
                narrative: "L2 discourages very large weights.",
                prompts: ["Increase L2 slightly.", "Run steps and compare stability."],
                setup: .regularizationChoice,
                completionRule: .l2AtLeast(0.001),
                quickQuestion: "L2 regularization encourages...",
                quickChoices: ["Smaller weights", "Bigger batches", "Fewer classes"],
                correctChoiceIndex: 0
            )
        ]
    }
}
