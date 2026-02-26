import Foundation

public enum OutputMode: String, CaseIterable, Identifiable {
    case sigmoid = "Sigmoid"
    case softmax = "Softmax"

    public var id: String { rawValue }
}

public struct MLPConfiguration {
    public var hiddenLayerSizes: [Int]
    public var activation: ActivationKind
    public var outputMode: OutputMode
    public var dropout: Float
    public var l2: Float
    public var gradientClip: Float
    public var seed: UInt64

    public init(
        hiddenLayerSizes: [Int] = [16],
        activation: ActivationKind = .relu,
        outputMode: OutputMode = .sigmoid,
        dropout: Float = 0,
        l2: Float = 0,
        gradientClip: Float = 0,
        seed: UInt64 = 7
    ) {
        self.hiddenLayerSizes = hiddenLayerSizes
        self.activation = activation
        self.outputMode = outputMode
        self.dropout = dropout
        self.l2 = l2
        self.gradientClip = gradientClip
        self.seed = seed
    }
}

public struct LayerInspection {
    public var name: String
    public var weights: Tensor
    public var activations: Tensor
    public var gradients: Tensor?

    public init(name: String, weights: Tensor, activations: Tensor, gradients: Tensor?) {
        self.name = name
        self.weights = weights
        self.activations = activations
        self.gradients = gradients
    }
}

public struct TrainStepReport {
    public var loss: Float
    public var trainAccuracy: Float
    public var phase: TrainingPhase
    public var phaseMessages: [String]
    public var layerInspections: [LayerInspection]
    public var tensorSummaries: [TensorSummary]
}

public final class MLPNetwork {
    public private(set) var configuration: MLPConfiguration
    public private(set) var layers: [DenseLayer] = []

    private var rng: SeededGenerator
    private var sgdOptimizer = SGDOptimizer()
    private var adamOptimizer = AdamOptimizer()

    public init(configuration: MLPConfiguration) {
        self.configuration = configuration
        self.rng = SeededGenerator(seed: configuration.seed)
        rebuild(configuration: configuration)
    }

    public func rebuild(configuration: MLPConfiguration) {
        self.configuration = configuration
        self.rng = SeededGenerator(seed: configuration.seed)

        var layerSizes = [2]
        layerSizes.append(contentsOf: configuration.hiddenLayerSizes)
        layerSizes.append(configuration.outputMode == .sigmoid ? 1 : 2)

        layers = []
        for i in 0..<(layerSizes.count - 1) {
            layers.append(DenseLayer(inputSize: layerSizes[i], outputSize: layerSizes[i + 1], generator: &rng))
        }
    }

    public func predictProbability(x: Float, y: Float) -> Float {
        let input = Tensor(rows: 1, cols: 2, data: [x, y])
        let output = forward(input: input, training: false).output
        if configuration.outputMode == .sigmoid {
            return output[0, 0]
        }
        return output[0, 1]
    }

    public func accuracy(on points: [DataPoint]) -> Float {
        guard !points.isEmpty else { return 0 }
        let input = Tensor(rows: points.count, cols: 2, data: points.flatMap { [$0.x, $0.y] })
        let output = forward(input: input, training: false).output

        if configuration.outputMode == .sigmoid {
            let probs = (0..<output.rows).map { output[$0, 0] }
            return Math.binaryAccuracy(probabilities: probs, labels: points.map(\.label))
        }

        var correct = 0
        for r in 0..<output.rows {
            let pred = output[r, 1] > output[r, 0] ? 1 : 0
            if pred == points[r].label { correct += 1 }
        }
        return Float(correct) / Float(points.count)
    }

    public func trainStep(
        batchInput: Tensor,
        labels: [Int],
        learningRate: Float,
        optimizer: OptimizerType
    ) -> TrainStepReport {
        let forwardResult = forward(input: batchInput, training: true)
        let output = forwardResult.output

        let lossResult: LossResult
        if configuration.outputMode == .sigmoid {
            lossResult = Losses.binaryCrossEntropy(probabilities: output, labels: labels)
        } else {
            let logits = forwardResult.logits
            lossResult = Losses.softmaxCrossEntropy(logits: logits, labels: labels)
        }

        var delta = lossResult.gradient
        var gradWeights = Array(repeating: Tensor(rows: 1, cols: 1), count: layers.count)
        var layerInspections: [LayerInspection] = []

        for layerIndex in layers.indices.reversed() {
            if layerIndex < layers.count - 1 {
                let activated = forwardResult.activations[layerIndex + 1]
                let derivative = configuration.activation.derivative(forActivated: activated)
                delta = delta.hadamard(derivative)

                if configuration.dropout > 0 {
                    let mask = forwardResult.dropoutMasks[layerIndex]
                    delta = delta.hadamard(mask)
                    delta = delta / max(1 - configuration.dropout, 1e-5)
                }
            }

            let prevActivation = forwardResult.activations[layerIndex]
            let batchSize = Float(max(prevActivation.rows, 1))
            var gradW = Tensor.matmul(prevActivation.transposed(), delta) / batchSize
            if configuration.l2 > 0 {
                gradW = gradW + (layers[layerIndex].weights * configuration.l2)
            }

            var gradB = Array(repeating: Float(0), count: layers[layerIndex].outputSize)
            for c in 0..<delta.cols {
                var sum: Float = 0
                for r in 0..<delta.rows {
                    sum += delta[r, c]
                }
                gradB[c] = sum / batchSize
            }

            gradWeights[layerIndex] = gradW
            let propagated = Tensor.matmul(delta, layers[layerIndex].weights.transposed())

            switch optimizer {
            case .sgd:
                sgdOptimizer.update(
                    layerIndex: layerIndex,
                    layer: layers[layerIndex],
                    gradW: gradW,
                    gradB: gradB,
                    learningRate: learningRate,
                    clip: configuration.gradientClip > 0 ? configuration.gradientClip : nil
                )
            case .adam:
                adamOptimizer.update(
                    layerIndex: layerIndex,
                    layer: layers[layerIndex],
                    gradW: gradW,
                    gradB: gradB,
                    learningRate: learningRate,
                    clip: configuration.gradientClip > 0 ? configuration.gradientClip : nil
                )
            }

            delta = propagated
        }

        for i in layers.indices {
            layerInspections.append(
                LayerInspection(
                    name: "Layer \(i + 1)",
                    weights: layers[i].weights,
                    activations: forwardResult.activations[i + 1],
                    gradients: gradWeights[i]
                )
            )
        }

        let probabilities: [Float]
        if configuration.outputMode == .sigmoid {
            probabilities = (0..<lossResult.probabilities.rows).map { lossResult.probabilities[$0, 0] }
        } else {
            probabilities = (0..<lossResult.probabilities.rows).map { lossResult.probabilities[$0, 1] }
        }

        let trainAcc = Math.binaryAccuracy(probabilities: probabilities, labels: labels)

        let tensors = [
            TensorSummary(name: "Input batch", tensor: batchInput, meaning: "Your current mini-batch of points."),
            TensorSummary(name: "Output probabilities", tensor: lossResult.probabilities, meaning: "Model confidence per class."),
            TensorSummary(name: "Loss gradient", tensor: lossResult.gradient, meaning: "How strongly each output should change.")
        ]

        return TrainStepReport(
            loss: lossResult.loss,
            trainAccuracy: trainAcc,
            phase: .update,
            phaseMessages: [
                "Forward pass: predictions were computed.",
                "Loss: model error compared to true labels.",
                "Backward pass: gradients were propagated.",
                "Update: weights moved using \(optimizer.rawValue)."
            ],
            layerInspections: layerInspections,
            tensorSummaries: tensors
        )
    }

    private func forward(input: Tensor, training: Bool) -> (output: Tensor, logits: Tensor, activations: [Tensor], dropoutMasks: [Tensor]) {
        var activations: [Tensor] = [input]
        var dropoutMasks: [Tensor] = Array(repeating: Tensor(rows: 1, cols: 1, repeating: 1), count: max(layers.count - 1, 0))

        var current = input
        var lastLogits = input

        for i in layers.indices {
            let z = layers[i].forward(current)
            lastLogits = z

            if i == layers.count - 1 {
                if configuration.outputMode == .sigmoid {
                    current = ActivationKind.sigmoid.apply(to: z)
                } else {
                    current = Losses.softmax(z)
                }
            } else {
                current = configuration.activation.apply(to: z)

                if training, configuration.dropout > 0 {
                    let keep = max(1 - configuration.dropout, 1e-5)
                    var mask = Tensor(rows: current.rows, cols: current.cols, repeating: 1)
                    for idx in mask.data.indices {
                        mask.data[idx] = rng.nextFloat() < keep ? 1 : 0
                    }
                    current = current.hadamard(mask) / keep
                    dropoutMasks[i] = mask
                } else if i < dropoutMasks.count {
                    dropoutMasks[i] = Tensor(rows: current.rows, cols: current.cols, repeating: 1)
                }
            }

            activations.append(current)
        }

        return (current, lastLogits, activations, dropoutMasks)
    }
}
