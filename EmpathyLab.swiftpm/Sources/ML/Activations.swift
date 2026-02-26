import Foundation

public enum ActivationKind: String, CaseIterable, Identifiable {
    case relu = "ReLU"
    case tanh = "tanh"
    case sigmoid = "sigmoid"

    public var id: String { rawValue }

    public func apply(_ value: Float) -> Float {
        switch self {
        case .relu: return max(0, value)
        case .tanh: return Math.tanh(value)
        case .sigmoid: return Math.sigmoid(value)
        }
    }

    public func derivativeFromActivated(_ value: Float) -> Float {
        switch self {
        case .relu: return value > 0 ? 1 : 0
        case .tanh: return 1 - value * value
        case .sigmoid: return value * (1 - value)
        }
    }

    public func apply(to tensor: Tensor) -> Tensor {
        tensor.map(apply)
    }

    public func derivative(forActivated tensor: Tensor) -> Tensor {
        tensor.map(derivativeFromActivated)
    }
}
