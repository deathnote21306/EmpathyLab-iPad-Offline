import Foundation

public struct Tensor: Equatable {
    public var rows: Int
    public var cols: Int
    public var data: [Float]

    public init(rows: Int, cols: Int, repeating value: Float = 0) {
        self.rows = rows
        self.cols = cols
        self.data = Array(repeating: value, count: rows * cols)
    }

    public init(rows: Int, cols: Int, data: [Float]) {
        self.rows = rows
        self.cols = cols
        self.data = data
    }

    public var shape: [Int] { [rows, cols] }

    public subscript(_ r: Int, _ c: Int) -> Float {
        get { data[r * cols + c] }
        set { data[r * cols + c] = newValue }
    }

    public static func random(
        rows: Int,
        cols: Int,
        in range: ClosedRange<Float>,
        generator: inout SeededGenerator
    ) -> Tensor {
        var values: [Float] = []
        values.reserveCapacity(rows * cols)
        for _ in 0..<(rows * cols) {
            values.append(generator.nextFloat(in: range))
        }
        return Tensor(rows: rows, cols: cols, data: values)
    }

    public func transposed() -> Tensor {
        var result = Tensor(rows: cols, cols: rows)
        for r in 0..<rows {
            for c in 0..<cols {
                result[c, r] = self[r, c]
            }
        }
        return result
    }

    public func map(_ transform: (Float) -> Float) -> Tensor {
        Tensor(rows: rows, cols: cols, data: data.map(transform))
    }

    public func hadamard(_ other: Tensor) -> Tensor {
        var result = Tensor(rows: rows, cols: cols)
        for i in data.indices {
            result.data[i] = data[i] * other.data[i]
        }
        return result
    }

    public func clipped(limit: Float?) -> Tensor {
        guard let limit, limit > 0 else { return self }
        return map { Math.clamp($0, min: -limit, max: limit) }
    }

    public func sampleValues(_ count: Int = 8) -> [Float] {
        Array(data.prefix(count))
    }

    public var minValue: Float { data.min() ?? 0 }
    public var maxValue: Float { data.max() ?? 0 }
    public var meanValue: Float { Math.mean(data) }

    public static func +(lhs: Tensor, rhs: Tensor) -> Tensor {
        var out = lhs
        for i in out.data.indices { out.data[i] += rhs.data[i] }
        return out
    }

    public static func -(lhs: Tensor, rhs: Tensor) -> Tensor {
        var out = lhs
        for i in out.data.indices { out.data[i] -= rhs.data[i] }
        return out
    }

    public static func *(lhs: Tensor, rhs: Float) -> Tensor {
        lhs.map { $0 * rhs }
    }

    public static func /(lhs: Tensor, rhs: Float) -> Tensor {
        lhs.map { $0 / rhs }
    }

    public static func matmul(_ a: Tensor, _ b: Tensor) -> Tensor {
        precondition(a.cols == b.rows, "Tensor shapes incompatible for matmul")
        var out = Tensor(rows: a.rows, cols: b.cols)
        for r in 0..<a.rows {
            for c in 0..<b.cols {
                var sum: Float = 0
                for k in 0..<a.cols {
                    sum += a[r, k] * b[k, c]
                }
                out[r, c] = sum
            }
        }
        return out
    }
}
