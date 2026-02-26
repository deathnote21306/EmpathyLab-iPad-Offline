import Foundation

public final class RunTimer {
    private var startedAt: Date?

    public init() {}

    public func start() {
        startedAt = Date()
    }

    @discardableResult
    public func stop() -> Int {
        guard let startedAt else { return 0 }
        let elapsed = Date().timeIntervalSince(startedAt)
        self.startedAt = nil
        return max(0, Int(elapsed.rounded()))
    }

    public func reset() {
        startedAt = nil
    }
}
