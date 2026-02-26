import SwiftUI

public struct LabeledSlider: View {
    public let title: String
    @Binding public var value: Double
    public let range: ClosedRange<Double>
    public let step: Double
    public var formatter: (Double) -> String

    public init(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 0.01,
        formatter: @escaping (Double) -> String = { String(format: "%.2f", $0) }
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.formatter = formatter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(Typography.caption)
                Spacer()
                Text(formatter(value))
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}
