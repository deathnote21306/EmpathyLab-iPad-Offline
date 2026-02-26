import SwiftUI

public struct MetricCard: View {
    public enum Trend {
        case up
        case down
    }

    public let title: String
    public let value: String
    public let subtitle: String
    public let trend: Trend?

    public init(
        title: String,
        value: String,
        subtitle: String,
        trend: Trend? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.trend = trend
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                if let trend {
                    Image(systemName: trend == .down ? "arrow.down" : "arrow.up")
                        .font(.caption)
                        .foregroundStyle(trend == .down ? .green : .orange)
                }
            }

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}
