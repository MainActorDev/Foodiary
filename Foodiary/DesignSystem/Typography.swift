import SwiftUI

// MARK: - Typography

enum FoodiaryTypography {
    static let display: Font = .system(size: 34, weight: .bold, design: .default)
    static let title: Font = .system(size: 20, weight: .bold, design: .default)
    static let body: Font = .system(size: 15, design: .default)
    static let bodyBold: Font = .system(size: 15, weight: .semibold, design: .default)
    static let bodySm: Font = .system(size: 13, design: .default)
    static let metric: Font = .system(size: 28, weight: .bold, design: .default)
    static let label: Font = .system(size: 11, weight: .bold, design: .default)
    static let button: Font = .system(size: 15, weight: .bold, design: .default)
    static let badge: Font = .system(size: 11, weight: .bold, design: .default)
    static let segment: Font = .system(size: 12, weight: .bold, design: .default)

    // Pulse v2 typography
    static let pulseDisplay: Font = .system(size: 38, weight: .heavy, design: .rounded).monospacedDigit()
    static let pulseMetric: Font = .system(size: 30, weight: .heavy, design: .rounded).monospacedDigit()
    static let pulseTitle: Font = .system(size: 22, weight: .bold, design: .rounded)
    static let pulseHeadline: Font = .system(size: 17, weight: .bold, design: .rounded)
    static let pulseBody: Font = .system(size: 15, weight: .regular, design: .default)
    static let pulseBodyBold: Font = .system(size: 15, weight: .semibold, design: .default)
    static let pulseCaption: Font = .system(size: 12, weight: .medium, design: .default)
    static let pulseLabel: Font = .system(size: 11, weight: .bold, design: .default)
}
