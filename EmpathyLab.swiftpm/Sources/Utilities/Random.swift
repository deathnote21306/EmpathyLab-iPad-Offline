import Foundation

public struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    public init(seed: UInt64) {
        self.state = seed == 0 ? 0xDEADBEEF : seed
    }

    public mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }

    public mutating func nextFloat() -> Float {
        Float(next() % UInt64(UInt32.max)) / Float(UInt32.max)
    }

    public mutating func nextFloat(in range: ClosedRange<Float>) -> Float {
        let t = nextFloat()
        return range.lowerBound + (range.upperBound - range.lowerBound) * t
    }
}
