import Foundation

public final class Debouncer {
    private var task: Task<Void, Never>?
    private let delayNanos: UInt64

    public init(milliseconds: Int) {
        self.delayNanos = UInt64(milliseconds) * 1_000_000
    }

    public func schedule(_ action: @escaping @MainActor () -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(nanoseconds: delayNanos)
            guard !Task.isCancelled else { return }
            await action()
        }
    }

    public func cancel() {
        task?.cancel()
    }
}
