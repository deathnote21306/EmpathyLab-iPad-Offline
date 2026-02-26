import Foundation

public enum RecipeDataChoice: String, CaseIterable, Identifiable {
    case points2D = "Points (2D)"
    case imagesSoon = "Images (coming soon)"
    case textSoon = "Text (coming soon)"

    public var id: String { rawValue }
}

public enum RecipeTaskChoice: String, CaseIterable, Identifiable {
    case classify = "Classify"
    case predictNumber = "Predict a number"

    public var id: String { rawValue }
}

public enum RecipeConstraintChoice: String, CaseIterable, Identifiable {
    case fast = "Fast"
    case balanced = "Balanced"
    case accurate = "Accurate"

    public var id: String { rawValue }
}

public struct RecipeAnswers {
    public var dataChoice: RecipeDataChoice
    public var taskChoice: RecipeTaskChoice
    public var constraintChoice: RecipeConstraintChoice

    public init(
        dataChoice: RecipeDataChoice,
        taskChoice: RecipeTaskChoice,
        constraintChoice: RecipeConstraintChoice
    ) {
        self.dataChoice = dataChoice
        self.taskChoice = taskChoice
        self.constraintChoice = constraintChoice
    }
}

public struct RecipeRecommendation {
    public var hiddenLayerSizes: [Int]
    public var activation: String
    public var learningRate: Float
    public var batchSize: Int
    public var dropout: Float
    public var l2: Float
    public var note: String
}

public enum RecipeEngine {
    public static func recommend(for answers: RecipeAnswers) -> RecipeRecommendation {
        switch answers.constraintChoice {
        case .fast:
            return RecipeRecommendation(
                hiddenLayerSizes: [8],
                activation: "relu",
                learningRate: 0.03,
                batchSize: 24,
                dropout: 0,
                l2: 0,
                note: "Fast setup: fewer neurons, bigger batches, quick feedback."
            )
        case .balanced:
            return RecipeRecommendation(
                hiddenLayerSizes: [16, 12],
                activation: "tanh",
                learningRate: 0.015,
                batchSize: 20,
                dropout: 0.1,
                l2: 0.0005,
                note: "Balanced setup: stable learning and better generalization."
            )
        case .accurate:
            return RecipeRecommendation(
                hiddenLayerSizes: [24, 16, 8],
                activation: "relu",
                learningRate: 0.008,
                batchSize: 16,
                dropout: 0.2,
                l2: 0.001,
                note: "Accuracy setup: richer model with stronger regularization."
            )
        }
    }
}
