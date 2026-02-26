import SwiftUI

struct LossChartView: View {
    let points: [TrainingHistoryPoint]

    var body: some View {
        GeometryReader { geo in
            let normalized = normalizedPoints(size: geo.size)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))

                Path { path in
                    guard let first = normalized.first else { return }
                    path.move(to: first)
                    for point in normalized.dropFirst() { path.addLine(to: point) }
                }
                .stroke(Theme.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
        }
    }

    private func normalizedPoints(size: CGSize) -> [CGPoint] {
        guard points.count > 1 else { return [] }
        let losses = points.map(\.loss)
        let minLoss = losses.min() ?? 0
        let maxLoss = max(losses.max() ?? 1, minLoss + 1e-5)

        return points.enumerated().map { idx, p in
            let x = CGFloat(idx) / CGFloat(max(points.count - 1, 1))
            let y = CGFloat((p.loss - minLoss) / (maxLoss - minLoss))
            return CGPoint(x: x * size.width, y: size.height - y * size.height)
        }
    }
}
