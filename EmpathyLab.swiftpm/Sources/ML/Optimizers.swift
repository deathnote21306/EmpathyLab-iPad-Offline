import Foundation

public enum OptimizerType: String, CaseIterable, Identifiable {
    case sgd = "SGD"
    case adam = "Adam"

    public var id: String { rawValue }
}

public protocol LayerOptimizer {
    mutating func update(
        layerIndex: Int,
        layer: DenseLayer,
        gradW: Tensor,
        gradB: [Float],
        learningRate: Float,
        clip: Float?
    )
}

public struct SGDOptimizer: LayerOptimizer {
    public init() {}

    public mutating func update(
        layerIndex: Int,
        layer: DenseLayer,
        gradW: Tensor,
        gradB: [Float],
        learningRate: Float,
        clip: Float?
    ) {
        let w = gradW.clipped(limit: clip)
        for i in layer.weights.data.indices {
            layer.weights.data[i] -= learningRate * w.data[i]
        }

        for i in layer.biases.indices {
            let g = clip.map { Math.clamp(gradB[i], min: -$0, max: $0) } ?? gradB[i]
            layer.biases[i] -= learningRate * g
        }
    }
}

public struct AdamOptimizer: LayerOptimizer {
    private var t: Int = 0
    private var mW: [Int: Tensor] = [:]
    private var vW: [Int: Tensor] = [:]
    private var mB: [Int: [Float]] = [:]
    private var vB: [Int: [Float]] = [:]

    private let beta1: Float = 0.9
    private let beta2: Float = 0.999
    private let epsilon: Float = 1e-8

    public init() {}

    public mutating func update(
        layerIndex: Int,
        layer: DenseLayer,
        gradW: Tensor,
        gradB: [Float],
        learningRate: Float,
        clip: Float?
    ) {
        t += 1

        let clippedW = gradW.clipped(limit: clip)
        let clippedB = gradB.map { value in
            if let clip {
                return Math.clamp(value, min: -clip, max: clip)
            }
            return value
        }

        if mW[layerIndex] == nil {
            mW[layerIndex] = Tensor(rows: clippedW.rows, cols: clippedW.cols)
            vW[layerIndex] = Tensor(rows: clippedW.rows, cols: clippedW.cols)
            mB[layerIndex] = Array(repeating: 0, count: clippedB.count)
            vB[layerIndex] = Array(repeating: 0, count: clippedB.count)
        }

        guard var mw = mW[layerIndex], var vw = vW[layerIndex], var mb = mB[layerIndex], var vb = vB[layerIndex] else {
            return
        }

        for i in clippedW.data.indices {
            mw.data[i] = beta1 * mw.data[i] + (1 - beta1) * clippedW.data[i]
            vw.data[i] = beta2 * vw.data[i] + (1 - beta2) * clippedW.data[i] * clippedW.data[i]

            let mHat = mw.data[i] / (1 - Foundation.pow(beta1, Float(t)))
            let vHat = vw.data[i] / (1 - Foundation.pow(beta2, Float(t)))
            layer.weights.data[i] -= learningRate * mHat / (Foundation.sqrt(vHat) + epsilon)
        }

        for i in clippedB.indices {
            mb[i] = beta1 * mb[i] + (1 - beta1) * clippedB[i]
            vb[i] = beta2 * vb[i] + (1 - beta2) * clippedB[i] * clippedB[i]

            let mHat = mb[i] / (1 - Foundation.pow(beta1, Float(t)))
            let vHat = vb[i] / (1 - Foundation.pow(beta2, Float(t)))
            layer.biases[i] -= learningRate * mHat / (Foundation.sqrt(vHat) + epsilon)
        }

        mW[layerIndex] = mw
        vW[layerIndex] = vw
        mB[layerIndex] = mb
        vB[layerIndex] = vb
    }
}
