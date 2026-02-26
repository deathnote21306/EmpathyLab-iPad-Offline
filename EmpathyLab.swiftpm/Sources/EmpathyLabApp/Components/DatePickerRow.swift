import SwiftUI

public struct DatePickerRow: View {
    public let title: String
    @Binding public var date: Date
    public let style: PayBillStyle

    @State private var isExpanded = false

    public init(
        title: String,
        date: Binding<Date>,
        style: PayBillStyle
    ) {
        self.title = title
        self._date = date
        self.style = style
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: style == .lab ? 8 : 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(style == .lab ? .caption : .headline)
                            .foregroundStyle(style.titleColor)
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(style == .lab ? .footnote : .body)
                            .foregroundStyle(style.textColor)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(style == .lab ? Color.gray : Color.blue)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(minHeight: style == .lab ? 34 : 48)

            if isExpanded {
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
            }
        }
        .padding(style == .lab ? 10 : 14)
        .background(style.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: style == .lab ? 8 : 14))
    }
}
