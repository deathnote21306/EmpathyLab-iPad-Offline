import Foundation

public enum DatasetKind: String, CaseIterable, Identifiable {
    case line = "Line"
    case circles = "Circles"
    case xor = "XOR"

    public var id: String { rawValue }
}

public struct DatasetConfig {
    public var kind: DatasetKind
    public var numberOfPoints: Int
    public var noise: Float
    public var seed: UInt64
    public var normalize: Bool
    public var validationRatio: Float

    public init(
        kind: DatasetKind = .line,
        numberOfPoints: Int = 220,
        noise: Float = 0.15,
        seed: UInt64 = 7,
        normalize: Bool = false,
        validationRatio: Float = 0.2
    ) {
        self.kind = kind
        self.numberOfPoints = numberOfPoints
        self.noise = noise
        self.seed = seed
        self.normalize = normalize
        self.validationRatio = validationRatio
    }
}

public struct Dataset {
    public var points: [DataPoint]
    public var normalized: Bool

    public var trainPoints: [DataPoint] {
        points.filter { $0.split == .train }
    }

    public var validationPoints: [DataPoint] {
        points.filter { $0.split == .validation }
    }

    public init(points: [DataPoint], normalized: Bool) {
        self.points = points
        self.normalized = normalized
    }

    public static func make(config: DatasetConfig) -> Dataset {
        var rng = SeededGenerator(seed: config.seed)
        var raw: [DataPoint] = []
        raw.reserveCapacity(config.numberOfPoints)

        for i in 0..<config.numberOfPoints {
            let base = sample(kind: config.kind, index: i, generator: &rng)
            var x = base.x + gaussianNoise(scale: config.noise, generator: &rng)
            var y = base.y + gaussianNoise(scale: config.noise, generator: &rng)
            if !(-1.5...1.5).contains(x) { x = Math.clamp(x, min: -1.5, max: 1.5) }
            if !(-1.5...1.5).contains(y) { y = Math.clamp(y, min: -1.5, max: 1.5) }
            raw.append(DataPoint(x: x, y: y, label: base.label, split: .train))
        }

        if config.normalize {
            normalize(points: &raw)
        }

        assignSplits(points: &raw, ratio: config.validationRatio, seed: config.seed &+ 99)
        return Dataset(points: raw, normalized: config.normalize)
    }

    public mutating func normalizeInPlace() {
        var mutable = points
        Self.normalize(points: &mutable)
        points = mutable
        normalized = true
    }

    private static func sample(kind: DatasetKind, index: Int, generator: inout SeededGenerator) -> (x: Float, y: Float, label: Int) {
        switch kind {
        case .line:
            let x = generator.nextFloat(in: -1...1)
            let y = generator.nextFloat(in: -1...1)
            let boundary = 0.35 * x + 0.05
            return (x, y, y > boundary ? 1 : 0)

        case .circles:
            let angle = generator.nextFloat(in: 0...(2 * .pi))
            let isOuter = index % 2 == 0
            let radius: Float = isOuter ? generator.nextFloat(in: 0.6...1.05) : generator.nextFloat(in: 0.05...0.45)
            let x = Foundation.cos(angle) * radius
            let y = Foundation.sin(angle) * radius
            return (x, y, isOuter ? 1 : 0)

        case .xor:
            let x = generator.nextFloat(in: -1...1)
            let y = generator.nextFloat(in: -1...1)
            let label = (x >= 0 && y >= 0) || (x < 0 && y < 0) ? 0 : 1
            return (x, y, label)
        }
    }

    private static func gaussianNoise(scale: Float, generator: inout SeededGenerator) -> Float {
        guard scale > 0 else { return 0 }
        let u1 = max(generator.nextFloat(), 1e-6)
        let u2 = max(generator.nextFloat(), 1e-6)
        let z0 = Foundation.sqrt(-2 * Foundation.log(u1)) * Foundation.cos(2 * .pi * u2)
        return z0 * scale
    }

    private static func normalize(points: inout [DataPoint]) {
        guard !points.isEmpty else { return }
        let xs = points.map(\.x)
        let ys = points.map(\.y)
        let meanX = Math.mean(xs)
        let meanY = Math.mean(ys)
        let stdX = Math.std(xs)
        let stdY = Math.std(ys)

        for i in points.indices {
            points[i].x = (points[i].x - meanX) / stdX
            points[i].y = (points[i].y - meanY) / stdY
        }
    }

    private static func assignSplits(points: inout [DataPoint], ratio: Float, seed: UInt64) {
        guard !points.isEmpty else { return }
        var indices = Array(points.indices)
        var rng = SeededGenerator(seed: seed)

        for i in indices.indices.reversed() {
            let j = Int(rng.next() % UInt64(i + 1))
            indices.swapAt(i, j)
        }

        let validationCount = Int(Float(points.count) * Math.clamp(ratio, min: 0.05, max: 0.4))
        let validationSet = Set(indices.prefix(validationCount))

        for idx in points.indices {
            points[idx].split = validationSet.contains(idx) ? .validation : .train
        }
    }
}
