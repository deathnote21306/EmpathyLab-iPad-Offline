import SwiftUI

struct ScatterPlotView: View {
    let points: [DataPoint]

    var body: some View {
        GeometryReader { geometry in
            ForEach(points) { point in
                let xNorm = (point.x + 1.6) / 3.2
                let yNorm = (point.y + 1.6) / 3.2
                Circle()
                    .fill(point.label == 1 ? Theme.accent : Color.pink)
                    .frame(width: point.split == .train ? 7 : 5, height: point.split == .train ? 7 : 5)
                    .opacity(point.split == .train ? 0.9 : 0.5)
                    .position(
                        x: CGFloat(xNorm) * geometry.size.width,
                        y: geometry.size.height - CGFloat(yNorm) * geometry.size.height
                    )
            }
        }
    }
}
