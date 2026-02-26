import Foundation

public enum DiagnosticSeverity: Int, Comparable {
    case high = 0
    case medium = 1
    case low = 2

    public static func < (lhs: DiagnosticSeverity, rhs: DiagnosticSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public enum DiagnosticFix: Hashable {
    case reduceLearningRate
    case increaseLearningRate
    case increaseBatchSize
    case normalizeDataset
    case switchToSigmoidOutput
    case addDropout
    case enableEarlyStopping
    case addL2
    case enableGradientClip
}

public struct DiagnosticIssue: Identifiable, Hashable {
    public let id = UUID()
    public let severity: DiagnosticSeverity
    public let title: String
    public let message: String
    public let fixButtonTitle: String
    public let fix: DiagnosticFix

    public init(
        severity: DiagnosticSeverity,
        title: String,
        message: String,
        fixButtonTitle: String,
        fix: DiagnosticFix
    ) {
        self.severity = severity
        self.title = title
        self.message = message
        self.fixButtonTitle = fixButtonTitle
        self.fix = fix
    }
}
