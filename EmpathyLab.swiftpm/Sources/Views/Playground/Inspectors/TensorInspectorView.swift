import SwiftUI

struct TensorInspectorView: View {
    let tensor: TensorSummary
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(tensor.name)
                        .font(Typography.title)

                    Text(tensor.meaning)
                        .font(Typography.body)
                        .foregroundStyle(.secondary)

                    row("Shape", tensor.shape.map(String.init).joined(separator: " × "))
                    row("Min", String(format: "%.4f", tensor.minValue))
                    row("Max", String(format: "%.4f", tensor.maxValue))
                    row("Mean", String(format: "%.4f", tensor.meanValue))

                    Text("Sample values")
                        .font(Typography.section)
                        .padding(.top, 8)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
                        ForEach(Array(tensor.samples.enumerated()), id: \.offset) { idx, value in
                            Text(String(format: "[%d] %.3f", idx, value))
                                .font(.caption.monospaced())
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(24)
            }
            .navigationTitle("Tensor Inspector")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
