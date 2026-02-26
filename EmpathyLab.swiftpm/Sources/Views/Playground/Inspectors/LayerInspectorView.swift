import SwiftUI

struct LayerInspectorView: View {
    let inspections: [LayerInspection]

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Layer Inspector", systemImage: "square.grid.3x3.fill")
                    .font(Typography.section)

                if inspections.isEmpty {
                    Text("Run a few training steps to inspect activations and gradients.")
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(inspections.enumerated()), id: \.offset) { _, item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.name)
                                .font(.headline)
                            HStack(spacing: 10) {
                                heatmap(title: "Weights", tensor: item.weights)
                                heatmap(title: "Activations", tensor: item.activations)
                                if let grad = item.gradients {
                                    heatmap(title: "Gradients", tensor: grad)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    private func heatmap(title: String, tensor: Tensor) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Canvas { context, size in
                let rows = max(1, min(tensor.rows, 24))
                let cols = max(1, min(tensor.cols, 24))
                let cellW = size.width / CGFloat(cols)
                let cellH = size.height / CGFloat(rows)

                for r in 0..<rows {
                    for c in 0..<cols {
                        let sourceR = Int(Float(r) / Float(rows) * Float(max(tensor.rows - 1, 1)))
                        let sourceC = Int(Float(c) / Float(cols) * Float(max(tensor.cols - 1, 1)))
                        let v = tensor[sourceR, sourceC]
                        let normalized = Double(Math.clamp((v + 1) / 2, min: 0, max: 1))
                        let color = Color(red: normalized, green: 0.25, blue: 1 - normalized, opacity: 0.85)
                        let rect = CGRect(x: CGFloat(c) * cellW, y: CGFloat(r) * cellH, width: cellW + 0.3, height: cellH + 0.3)
                        context.fill(Path(rect), with: .color(color))
                    }
                }
            }
            .frame(width: 120, height: 92)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}
