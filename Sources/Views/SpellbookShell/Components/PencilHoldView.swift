import SwiftUI
import UIKit

/// Transparent overlay that detects a sustained touch (finger or Apple Pencil).
/// Reports 0→1 progress over `holdDuration` seconds, then calls `onComplete` once.
struct PencilHoldView: UIViewRepresentable {
    let holdDuration: TimeInterval
    let onProgress: (CGFloat) -> Void
    let onComplete: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(holdDuration: holdDuration, onProgress: onProgress, onComplete: onComplete)
    }

    func makeUIView(context: Context) -> HoldUIView {
        let v = HoldUIView()
        v.backgroundColor = .clear
        v.coordinator = context.coordinator
        return v
    }

    func updateUIView(_ uiView: HoldUIView, context: Context) {
        context.coordinator.onProgress = onProgress
        context.coordinator.onComplete = onComplete
    }

    // MARK: - Coordinator

    final class Coordinator {
        var onProgress: (CGFloat) -> Void
        var onComplete: () -> Void
        let holdDuration: TimeInterval

        private var startTime: Date?
        private var timer: Timer?
        private var didComplete = false

        init(holdDuration: TimeInterval,
             onProgress: @escaping (CGFloat) -> Void,
             onComplete: @escaping () -> Void) {
            self.holdDuration = holdDuration
            self.onProgress   = onProgress
            self.onComplete   = onComplete
        }

        func began() {
            guard !didComplete else { return }
            startTime = Date()
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
                self?.tick()
            }
        }

        func ended() {
            guard !didComplete else { return }
            timer?.invalidate()
            timer = nil
            startTime = nil
            onProgress(0)
        }

        private func tick() {
            guard let startTime else { ended(); return }
            let progress = min(CGFloat(Date().timeIntervalSince(startTime) / holdDuration), 1.0)
            onProgress(progress)
            if progress >= 1.0 {
                didComplete = true
                timer?.invalidate()
                timer = nil
                self.startTime = nil
                onComplete()
            }
        }

        deinit { timer?.invalidate() }
    }
}

// MARK: - UIView

final class HoldUIView: UIView {
    weak var coordinator: PencilHoldView.Coordinator?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        coordinator?.began()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        coordinator?.ended()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        coordinator?.ended()
    }
}
