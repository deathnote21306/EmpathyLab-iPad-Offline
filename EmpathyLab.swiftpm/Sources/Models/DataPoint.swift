import Foundation

public struct DataPoint: Identifiable, Hashable {
    public enum Split: String, CaseIterable, Hashable {
        case train
        case validation
    }

    public let id = UUID()
    public var x: Float
    public var y: Float
    public var label: Int
    public var split: Split

    public init(x: Float, y: Float, label: Int, split: Split) {
        self.x = x
        self.y = y
        self.label = label
        self.split = split
    }
}
