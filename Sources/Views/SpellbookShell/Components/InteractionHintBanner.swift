import SwiftUI

/// A floating hint banner that explains an available interaction to the user.
struct InteractionHintBanner: View {
    let icon: String   // SF Symbol name
    let text: String

    private let mana   = Color(red: 0.49, green: 0.38, blue: 1.0)
    private let spirit = Color(red: 0.24, green: 0.84, blue: 0.75)

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(spirit)
                .frame(width: 30)

            Text(text)
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.05, green: 0.03, blue: 0.14).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [mana.opacity(0.55), spirit.opacity(0.40)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: mana.opacity(0.25), radius: 14)
        .allowsHitTesting(false)
    }
}
