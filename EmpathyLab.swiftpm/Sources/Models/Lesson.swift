import Foundation

public enum LessonSetup: Hashable {
    case lineSeparable
    case xorNeedsHiddenLayer
    case learningRateStory
    case overfittingStory
    case activationChoice
    case regularizationChoice
}

public enum LessonCompletionRule: Hashable {
    case minimumSteps(Int)
    case validationAccuracy(Float)
    case hiddenLayersAtLeast(Int)
    case dropoutAtLeast(Float)
    case l2AtLeast(Float)
    case activationIs(String)
}

public struct Lesson: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let goal: String
    public let narrative: String
    public let prompts: [String]
    public let setup: LessonSetup
    public let completionRule: LessonCompletionRule
    public let quickQuestion: String
    public let quickChoices: [String]
    public let correctChoiceIndex: Int

    public init(
        title: String,
        goal: String,
        narrative: String,
        prompts: [String],
        setup: LessonSetup,
        completionRule: LessonCompletionRule,
        quickQuestion: String,
        quickChoices: [String],
        correctChoiceIndex: Int
    ) {
        self.title = title
        self.goal = goal
        self.narrative = narrative
        self.prompts = prompts
        self.setup = setup
        self.completionRule = completionRule
        self.quickQuestion = quickQuestion
        self.quickChoices = quickChoices
        self.correctChoiceIndex = correctChoiceIndex
    }
}
