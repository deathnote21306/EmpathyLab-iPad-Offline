import SwiftUI

struct LessonQuizView: View {
    let question: String
    let choices: [String]
    @Binding var selectedChoice: Int?
    let didSubmit: Bool
    let feedback: String
    let onSubmit: () -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Check")
                    .font(Typography.section)
                Text(question)
                    .font(Typography.body)

                ForEach(choices.indices, id: \.self) { index in
                    Button {
                        selectedChoice = index
                    } label: {
                        HStack {
                            Image(systemName: selectedChoice == index ? "largecircle.fill.circle" : "circle")
                            Text(choices[index])
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 6)
                }

                PrimaryActionButton(title: "Submit", systemImage: "checkmark", action: onSubmit)
                    .opacity(selectedChoice == nil ? 0.6 : 1)
                    .disabled(selectedChoice == nil)

                if didSubmit {
                    Text(feedback)
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
