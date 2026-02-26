import Foundation

public struct RunMetrics: Equatable {
    public var labTimeSeconds: Int?
    public var fixTimeSeconds: Int?
    public var labErrorCount: Int
    public var fixErrorCount: Int

    public init(
        labTimeSeconds: Int? = nil,
        fixTimeSeconds: Int? = nil,
        labErrorCount: Int = 0,
        fixErrorCount: Int = 0
    ) {
        self.labTimeSeconds = labTimeSeconds
        self.fixTimeSeconds = fixTimeSeconds
        self.labErrorCount = labErrorCount
        self.fixErrorCount = fixErrorCount
    }

    public var timeDeltaSeconds: Int? {
        guard let labTimeSeconds, let fixTimeSeconds else { return nil }
        return labTimeSeconds - fixTimeSeconds
    }

    public var errorDelta: Int {
        labErrorCount - fixErrorCount
    }

    public var timeImprovementPercent: Int? {
        guard let labTimeSeconds, let fixTimeSeconds, labTimeSeconds > 0 else { return nil }
        let ratio = Double(labTimeSeconds - fixTimeSeconds) / Double(labTimeSeconds)
        return Int((ratio * 100).rounded())
    }

    public static func format(seconds: Int?) -> String {
        guard let seconds else { return "--:--" }
        let minutes = max(seconds, 0) / 60
        let remainder = max(seconds, 0) % 60
        return String(format: "%d:%02d", minutes, remainder)
    }
}
