import Foundation
import SwiftUI

@MainActor
public final class PlaygroundViewModel: ObservableObject {
    @Published public var datasetKind: DatasetKind = .line
    @Published public var numberOfPoints: Double = 220
    @Published public var noise: Double = 0.16
    @Published public var seed: Double = 7
    @Published public var normalizeData: Bool = false

    @Published public var hiddenLayerCount: Int = 1
    @Published public var hiddenLayer1: Double = 16
    @Published public var hiddenLayer2: Double = 12
    @Published public var hiddenLayer3: Double = 8
    @Published public var activation: ActivationKind = .relu
    @Published public var outputMode: OutputMode = .sigmoid
    @Published public var dropout: Double = 0
    @Published public var l2: Double = 0
    @Published public var gradientClip: Double = 0
    @Published public var optimizerType: OptimizerType = .adam

    @Published public var learningRate: Double = 0.015
    @Published public var batchSize: Double = 20
    @Published public var earlyStoppingEnabled: Bool = false

    @Published public var dataset: Dataset
    @Published public var trainingPhase: TrainingPhase = .idle
    @Published public var phaseMessages: [String] = []
    @Published public var lossHistory: [TrainingHistoryPoint] = []
    @Published public var trainAccuracy: Float = 0
    @Published public var validationAccuracy: Float = 0

    @Published public var decisionBoundary: [Float] = []
    @Published public var boundaryResolution: Int = 50

    @Published public var layerInspections: [LayerInspection] = []
    @Published public var tensorSummaries: [TensorSummary] = []
    @Published public var selectedTensor: TensorSummary?
    @Published public var showTensorInspector = false

    @Published public var currentStep: Int = 0
    @Published public var isPlaying = false

    private var model: MLPNetwork
    private var playerTask: Task<Void, Never>?
    private var batchRng = SeededGenerator(seed: 1337)

    public init() {
        let config = DatasetConfig()
        let initialDataset = Dataset.make(config: config)
        self.dataset = initialDataset

        let modelConfig = MLPConfiguration(
            hiddenLayerSizes: [16],
            activation: .relu,
            outputMode: .sigmoid,
            dropout: 0,
            l2: 0,
            gradientClip: 0,
            seed: 7
        )
        self.model = MLPNetwork(configuration: modelConfig)

        computeBoundary()
    }

    public var hiddenSizes: [Int] {
        var widths: [Int] = [Int(hiddenLayer1)]
        if hiddenLayerCount >= 2 { widths.append(Int(hiddenLayer2)) }
        if hiddenLayerCount >= 3 { widths.append(Int(hiddenLayer3)) }
        return widths.map { max($0, 2) }
    }

    public func regenerateDataset() {
        let config = DatasetConfig(
            kind: datasetKind,
            numberOfPoints: Int(numberOfPoints),
            noise: Float(noise),
            seed: UInt64(seed.rounded()),
            normalize: normalizeData,
            validationRatio: 0.2
        )
        dataset = Dataset.make(config: config)
        resetTraining(keepDataset: true)
        computeBoundary()
    }

    public func rebuildModel() {
        model.rebuild(
            configuration: MLPConfiguration(
                hiddenLayerSizes: hiddenSizes,
                activation: activation,
                outputMode: outputMode,
                dropout: Float(dropout),
                l2: Float(l2),
                gradientClip: Float(gradientClip),
                seed: UInt64(seed.rounded())
            )
        )
        resetTraining(keepDataset: true)
        computeBoundary()
    }

    public func normalizeDatasetNow() {
        dataset.normalizeInPlace()
        normalizeData = true
        resetTraining(keepDataset: true)
    }

    public func resetTraining(keepDataset: Bool) {
        pauseTraining()
        currentStep = 0
        trainingPhase = .idle
        phaseMessages = []
        lossHistory = []
        trainAccuracy = 0
        validationAccuracy = 0
        layerInspections = []
        tensorSummaries = []
        selectedTensor = nil
        showTensorInspector = false
        if !keepDataset {
            regenerateDataset()
        }
    }

    public func resetEverything() {
        datasetKind = .line
        numberOfPoints = 220
        noise = 0.16
        seed = 7
        normalizeData = false

        hiddenLayerCount = 1
        hiddenLayer1 = 16
        hiddenLayer2 = 12
        hiddenLayer3 = 8
        activation = .relu
        outputMode = .sigmoid
        dropout = 0
        l2 = 0
        gradientClip = 0
        optimizerType = .adam

        learningRate = 0.015
        batchSize = 20
        earlyStoppingEnabled = false

        regenerateDataset()
        rebuildModel()
    }

    public func togglePlayPause() {
        isPlaying ? pauseTraining() : playTraining()
    }

    public func playTraining() {
        guard !isPlaying else { return }
        isPlaying = true
        playerTask?.cancel()
        playerTask = Task {
            while !Task.isCancelled && isPlaying {
                stepTraining()
                try? await Task.sleep(nanoseconds: 140_000_000)
            }
        }
    }

    public func pauseTraining() {
        isPlaying = false
        playerTask?.cancel()
        playerTask = nil
    }

    public func stepTraining() {
        guard !dataset.trainPoints.isEmpty else { return }
        currentStep += 1

        let batch = makeBatch(from: dataset.trainPoints, size: Int(batchSize))
        let report = model.trainStep(
            batchInput: batch.input,
            labels: batch.labels,
            learningRate: Float(learningRate),
            optimizer: optimizerType
        )

        trainingPhase = report.phase
        phaseMessages = report.phaseMessages
        trainAccuracy = report.trainAccuracy
        layerInspections = report.layerInspections
        tensorSummaries = report.tensorSummaries

        validationAccuracy = model.accuracy(on: dataset.validationPoints)

        lossHistory.append(
            TrainingHistoryPoint(
                step: currentStep,
                loss: report.loss,
                trainAccuracy: trainAccuracy,
                validationAccuracy: validationAccuracy
            )
        )

        if lossHistory.count > 200 {
            lossHistory.removeFirst(lossHistory.count - 200)
        }

        if currentStep % 2 == 0 {
            computeBoundary()
        }

        if earlyStoppingEnabled,
           lossHistory.count > 25,
           let last = lossHistory.last?.validationAccuracy,
           let earlier = lossHistory.dropLast(10).last?.validationAccuracy,
           last + 0.03 < earlier {
            pauseTraining()
        }
    }

    public func applyRecipe(_ recommendation: RecipeRecommendation) {
        let layers = recommendation.hiddenLayerSizes
        hiddenLayerCount = max(1, min(3, layers.count))
        hiddenLayer1 = Double(layers[safe: 0] ?? 12)
        hiddenLayer2 = Double(layers[safe: 1] ?? 12)
        hiddenLayer3 = Double(layers[safe: 2] ?? 8)
        activation = recommendation.activation == "tanh" ? .tanh : .relu
        learningRate = Double(recommendation.learningRate)
        batchSize = Double(recommendation.batchSize)
        dropout = Double(recommendation.dropout)
        l2 = Double(recommendation.l2)
        rebuildModel()
    }

    public func applyLessonSetup(_ setup: LessonSetup) {
        switch setup {
        case .lineSeparable:
            datasetKind = .line
            noise = 0.08
            normalizeData = true
            hiddenLayerCount = 1
            hiddenLayer1 = 8
            activation = .relu
            learningRate = 0.02
            dropout = 0
            l2 = 0
        case .xorNeedsHiddenLayer:
            datasetKind = .xor
            noise = 0.1
            normalizeData = true
            hiddenLayerCount = 1
            hiddenLayer1 = 6
            activation = .tanh
            learningRate = 0.02
        case .learningRateStory:
            datasetKind = .line
            noise = 0.15
            normalizeData = true
            hiddenLayerCount = 1
            hiddenLayer1 = 10
            learningRate = 0.25
        case .overfittingStory:
            datasetKind = .circles
            noise = 0.06
            normalizeData = true
            hiddenLayerCount = 3
            hiddenLayer1 = 28
            hiddenLayer2 = 20
            hiddenLayer3 = 12
            dropout = 0
            l2 = 0
            learningRate = 0.01
        case .activationChoice:
            datasetKind = .xor
            noise = 0.08
            hiddenLayerCount = 2
            hiddenLayer1 = 14
            hiddenLayer2 = 10
            activation = .relu
            learningRate = 0.015
        case .regularizationChoice:
            datasetKind = .circles
            noise = 0.12
            hiddenLayerCount = 2
            hiddenLayer1 = 20
            hiddenLayer2 = 16
            dropout = 0
            l2 = 0
            learningRate = 0.012
        }

        regenerateDataset()
        rebuildModel()
    }

    public func boundaryProbability(atX x: Float, y: Float) -> Float {
        model.predictProbability(x: x, y: y)
    }

    private func computeBoundary() {
        let resolution = max(boundaryResolution, 12)
        let axis = linspace(from: -1.6, to: 1.6, count: resolution)
        var values: [Float] = []
        values.reserveCapacity(resolution * resolution)

        for y in axis.reversed() {
            for x in axis {
                values.append(model.predictProbability(x: x, y: y))
            }
        }
        decisionBoundary = values
    }

    private func makeBatch(from points: [DataPoint], size: Int) -> (input: Tensor, labels: [Int]) {
        let actualSize = max(2, min(size, points.count))
        var selected: [DataPoint] = []
        selected.reserveCapacity(actualSize)

        for _ in 0..<actualSize {
            let index = Int(batchRng.next() % UInt64(points.count))
            selected.append(points[index])
        }

        let input = Tensor(rows: selected.count, cols: 2, data: selected.flatMap { [$0.x, $0.y] })
        let labels = selected.map(\.label)
        return (input, labels)
    }

    private func linspace(from: Float, to: Float, count: Int) -> [Float] {
        guard count > 1 else { return [from] }
        let step = (to - from) / Float(count - 1)
        return (0..<count).map { from + Float($0) * step }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
