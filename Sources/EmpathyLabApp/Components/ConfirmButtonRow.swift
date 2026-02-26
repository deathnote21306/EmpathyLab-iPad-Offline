import SwiftUI

public struct ConfirmButtonRow: View {
    public let title: String
    public let isEnabled: Bool
    public let action: () -> Void
    public let style: PayBillStyle

    public init(
        title: String,
        isEnabled: Bool,
        action: @escaping () -> Void,
        style: PayBillStyle
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
        self.style = style
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: style == .lab ? 6 : 10) {
            Button(action: action) {
                Text(title)
                    .font(style == .lab ? .footnote : .headline)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: style == .lab ? 36 : 48)
            }
            .buttonStyle(.plain)
            .foregroundStyle(buttonForeground)
            .background(buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: style == .lab ? 7 : 12))
            .disabled(!isEnabled)

            Text(helperText)
                .font(style == .lab ? .caption2 : .caption)
                .foregroundStyle(style == .lab ? .secondary : .primary)
        }
    }

    private var buttonForeground: Color {
        if style == .lab {
            return isEnabled ? Color(red: 0.25, green: 0.25, blue: 0.28) : Color.gray
        }
        return .white
    }

    private var buttonBackground: Color {
        if style == .lab {
            return isEnabled ? Color(red: 0.82, green: 0.82, blue: 0.85) : Color.gray.opacity(0.35)
        }
        return isEnabled ? Color.blue : Color.gray.opacity(0.45)
    }

    private var helperText: String {
        if style == .lab {
            return isEnabled ? "Tap to continue" : "Enter a value"
        }
        return isEnabled ? "Looks good. You can confirm now." : "Enter a valid amount to enable confirmation."
    }
}
