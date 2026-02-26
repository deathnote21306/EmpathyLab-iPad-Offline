import Foundation

public enum TrainingPhase: String {
    case idle = "Idle"
    case forward = "Forward pass"
    case loss = "Loss"
    case backward = "Backward pass"
    case update = "Weight update"
}

public struct TrainingHistoryPoint: Identifiable {
    public var id = UUID()
    public var step: Int
    public var loss: Float
    public var trainAccuracy: Float
    public var validationAccuracy: Float

    public init(step: Int, loss: Float, trainAccuracy: Float, validationAccuracy: Float) {
        self.step = step
        self.loss = loss
        self.trainAccuracy = trainAccuracy
        self.validationAccuracy = validationAccuracy
    }
}

public struct TensorSummary: Identifiable {
    public var id = UUID()
    public var name: String
    public var shape: [Int]
    public var minValue: Float
    public var maxValue: Float
    public var meanValue: Float
    public var samples: [Float]
    public var meaning: String

    public init(name: String, tensor: Tensor, meaning: String) {
        self.name = name
        self.shape = tensor.shape
        self.minValue = tensor.minValue
        self.maxValue = tensor.maxValue
        self.meanValue = tensor.meanValue
        self.samples = tensor.sampleValues(10)
        self.meaning = meaning
    }
}
