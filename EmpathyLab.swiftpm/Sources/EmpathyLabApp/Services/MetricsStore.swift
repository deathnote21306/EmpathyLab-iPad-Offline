import Foundation
import SwiftUI

public final class MetricsStore: ObservableObject {
    public static let shared = MetricsStore()

    @Published public var metrics = RunMetrics()

    private let labTimer = RunTimer()
    private let fixTimer = RunTimer()

    private init() {}

    public func resetAll() {
        labTimer.reset()
        fixTimer.reset()
        metrics = RunMetrics()
    }

    public func startLab() {
        labTimer.start()
        metrics.labTimeSeconds = nil
        metrics.labErrorCount = 0
    }

    public func finishLab() {
        metrics.labTimeSeconds = labTimer.stop()
    }

    public func registerLabError() {
        metrics.labErrorCount += 1
    }

    public func startFix() {
        fixTimer.start()
        metrics.fixTimeSeconds = nil
        metrics.fixErrorCount = 0
    }

    public func finishFix() {
        metrics.fixTimeSeconds = fixTimer.stop()
    }

    public func registerFixError() {
        metrics.fixErrorCount += 1
    }
}
