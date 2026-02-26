import Foundation

public final class DenseLayer {
    public let inputSize: Int
    public let outputSize: Int
    public var weights: Tensor
    public var biases: [Float]

    public init(inputSize: Int, outputSize: Int, generator: inout SeededGenerator) {
        self.inputSize = inputSize
        self.outputSize = outputSize
        let scale: Float = Foundation.sqrt(2 / Float(max(inputSize, 1)))
        self.weights = Tensor.random(rows: inputSize, cols: outputSize, in: -scale...scale, generator: &generator)
        self.biases = Array(repeating: 0, count: outputSize)
    }

    public func forward(_ input: Tensor) -> Tensor {
        var out = Tensor.matmul(input, weights)
        for r in 0..<out.rows {
            for c in 0..<out.cols {
                out[r, c] += biases[c]
            }
        }
        return out
    }
}
