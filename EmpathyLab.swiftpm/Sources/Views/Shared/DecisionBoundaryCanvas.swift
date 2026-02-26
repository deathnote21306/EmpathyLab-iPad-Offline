import SwiftUI

struct DecisionBoundaryCanvas: View {
    let values: [Float]
    let resolution: Int

    var body: some View {
        Canvas { context, size in
            guard resolution > 1, values.count == resolution * resolution else { return }
            let cw = size.width / CGFloat(resolution)
            let ch = size.height / CGFloat(resolution)

            for row in 0..<resolution {
                for col in 0..<resolution {
                    let index = row * resolution + col
                    let p = Double(Math.clamp(values[index], min: 0, max: 1))
                    let color = Color(
                        red: 0.25 + 0.5 * p,
                        green: 0.3 + 0.2 * (1 - p),
                        blue: 0.82 - 0.5 * p,
                        opacity: 0.45
                    )
                    let rect = CGRect(x: CGFloat(col) * cw, y: CGFloat(row) * ch, width: cw + 0.4, height: ch + 0.4)
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
