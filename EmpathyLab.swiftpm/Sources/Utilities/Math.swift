import Foundation

public enum Math {
    public static func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        Swift.max(min, Swift.min(max, value))
    }

    public static func sigmoid(_ x: Float) -> Float {
        1 / (1 + Foundation.exp(-x))
    }

    public static func tanh(_ x: Float) -> Float {
        Foundation.tanhf(x)
    }

    public static func safeLog(_ x: Float) -> Float {
        Foundation.log(max(x, 1e-7))
    }

    public static func mean(_ values: [Float]) -> Float {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Float(values.count)
    }

    public static func std(_ values: [Float]) -> Float {
        guard values.count > 1 else { return 1 }
        let m = mean(values)
        let variance = values.reduce(0) { $0 + ($1 - m) * ($1 - m) } / Float(values.count)
        return max(Foundation.sqrt(variance), 1e-6)
    }

    public static func binaryAccuracy(probabilities: [Float], labels: [Int]) -> Float {
        guard probabilities.count == labels.count, !labels.isEmpty else { return 0 }
        let correct = zip(probabilities, labels).filter { prob, label in
            (prob >= 0.5 ? 1 : 0) == label
        }.count
        return Float(correct) / Float(labels.count)
    }
}
