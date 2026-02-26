import Foundation

public struct LossResult {
    public let loss: Float
    public let gradient: Tensor
    public let probabilities: Tensor
}

public enum Losses {
    public static func binaryCrossEntropy(probabilities: Tensor, labels: [Int]) -> LossResult {
        precondition(probabilities.cols == 1)
        let batchSize = Float(probabilities.rows)
        var grad = Tensor(rows: probabilities.rows, cols: 1)
        var loss: Float = 0

        for i in 0..<probabilities.rows {
            let p = Math.clamp(probabilities[i, 0], min: 1e-6, max: 1 - 1e-6)
            let y = Float(labels[i])
            loss += -(y * Math.safeLog(p) + (1 - y) * Math.safeLog(1 - p))
            grad[i, 0] = (p - y) / batchSize
        }

        return LossResult(loss: loss / batchSize, gradient: grad, probabilities: probabilities)
    }

    public static func softmax(_ logits: Tensor) -> Tensor {
        var output = Tensor(rows: logits.rows, cols: logits.cols)

        for r in 0..<logits.rows {
            var maxLogit: Float = -.greatestFiniteMagnitude
            for c in 0..<logits.cols {
                maxLogit = max(maxLogit, logits[r, c])
            }

            var sumExp: Float = 0
            for c in 0..<logits.cols {
                let v = Foundation.exp(logits[r, c] - maxLogit)
                output[r, c] = v
                sumExp += v
            }

            for c in 0..<logits.cols {
                output[r, c] /= max(sumExp, 1e-6)
            }
        }

        return output
    }

    public static func softmaxCrossEntropy(logits: Tensor, labels: [Int]) -> LossResult {
        let probs = softmax(logits)
        let batchSize = Float(logits.rows)
        var grad = probs
        var loss: Float = 0

        for r in 0..<probs.rows {
            let label = labels[r]
            let p = Math.clamp(probs[r, label], min: 1e-6, max: 1)
            loss += -Math.safeLog(p)
            grad[r, label] -= 1
        }

        grad = grad / batchSize
        return LossResult(loss: loss / batchSize, gradient: grad, probabilities: probs)
    }
}
