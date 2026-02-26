import SwiftUI

public struct PrimaryActionButton: View {
    public let title: String
    public let systemImage: String?
    public let action: () -> Void

    public init(title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(Theme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
