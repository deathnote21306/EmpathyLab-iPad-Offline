import SwiftUI

public enum Theme {
    public static let accent = Color(red: 0.28, green: 0.62, blue: 1.0)
    public static let success = Color(red: 0.3, green: 0.8, blue: 0.5)

    public static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.10, blue: 0.18),
            Color(red: 0.10, green: 0.16, blue: 0.27),
            Color(red: 0.15, green: 0.21, blue: 0.32)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let cardBackground = Color.white.opacity(0.14)
    public static let cardBorder = Color.white.opacity(0.24)
}
