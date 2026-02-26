import SwiftUI

public enum PayBillStyle {
    case lab
    case fix

    var cardBackground: Color {
        switch self {
        case .lab:
            return Color(red: 0.93, green: 0.93, blue: 0.95)
        case .fix:
            return Color(.secondarySystemBackground)
        }
    }

    var titleColor: Color {
        switch self {
        case .lab:
            return Color.gray
        case .fix:
            return Color.primary
        }
    }

    var textColor: Color {
        switch self {
        case .lab:
            return Color(red: 0.35, green: 0.35, blue: 0.38)
        case .fix:
            return Color.primary
        }
    }

    var borderColor: Color {
        switch self {
        case .lab:
            return Color.gray.opacity(0.3)
        case .fix:
            return Color.blue.opacity(0.35)
        }
    }
}

public struct AmountField: View {
    public let title: String
    public let placeholder: String
    @Binding public var text: String
    public let style: PayBillStyle

    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        style: PayBillStyle
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.style = style
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: style == .lab ? 6 : 10) {
            Text(title)
                .font(style == .lab ? .caption : .headline)
                .foregroundStyle(style.titleColor)

            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(style.textColor)
                .padding(style == .lab ? 9 : 14)
                .frame(minHeight: style == .lab ? 34 : 48)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: style == .lab ? 6 : 10)
                        .stroke(style.borderColor, lineWidth: 1)
                )
        }
        .padding(style == .lab ? 10 : 14)
        .background(style.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: style == .lab ? 8 : 14))
    }
}
