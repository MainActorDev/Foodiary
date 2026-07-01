import SwiftUI

// MARK: - Pulse v2 / Calorie Ring Design Colors

enum FoodiaryDesign {
    // Pulse v2 tokens — clean, modern planning cockpit
    static let pulseBackground = Color(hex: "F6F7FF")
    static let pulseBackgroundAlt = Color(hex: "F8FAFF")
    static let pulseSurface = Color.white
    static let pulseSurfaceSoft = Color(hex: "EEF0FF")
    static let pulseSurfaceMint = Color(hex: "E6FBF3")
    static let pulsePrimary = Color(hex: "4BB8FA")
    static let pulsePrimaryLight = Color(hex: "DEF0FF")
    static let pulsePrimaryDark = Color(hex: "0B4F8C")
    static let pulseMint = Color(hex: "10B981")
    static let pulseMintLight = Color(hex: "D1FAE5")
    static let pulseCyan = Color(hex: "38BDF8")
    static let pulseCyanLight = Color(hex: "E0F6FF")
    static let pulseAmber = Color(hex: "F59E0B")
    static let pulseAmberLight = Color(hex: "FEF3C7")
    static let pulseInk = Color(hex: "15142A")
    static let pulseMuted = Color(hex: "6B6880")
    static let pulseBorder = Color(hex: "C8C6D0")
    static let pulseDivider = Color(hex: "E8E6F0")
    static let pulseDanger = Color(hex: "EF4444")
    static let pulseDangerLight = Color(hex: "FEE2E2")

    // Day pill state colors (from prototype)
    static let pulseDayEmpty = Color(hex: "FFF7ED")
    static let pulseDayEmptyFg = Color(hex: "B45309")
    static let pulseDayFuture = Color(hex: "E6FBF3")
    static let pulseDayFutureFg = Color(hex: "047857")
    static let pulseDayActiveFg = Color.white

    static let accent = Color(hex: "2563EB")       // Blue
    static let accentLight = Color(hex: "DBEAFE")
    static let secondary = Color(hex: "059669")     // Green
    static let secondaryLight = Color(hex: "D1FAE5")
    static let warning = Color(hex: "D97706")       // Amber
    static let warningLight = Color(hex: "FEF3C7")
    static let background = Color(hex: "F8FAFC")
    static let black = Color(hex: "0F172A")
    static let white = Color.white
    static let muted = Color(hex: "F1F5F9")
    static let mutedFg = Color(hex: "64748B")
    static let border = Color(hex: "CBD5E1")
    static let divider = Color(hex: "F1F5F9")

    // Legacy aliases for backward compat during migration
    static let coral = accent
    static let mint = secondary
    static let yellow = warning

    static func pulseMealTint(for mealType: Meal.MealType) -> Color {
        switch mealType {
        case .breakfast: return Color(hex: "FFF4D8")
        case .lunch: return pulseMintLight
        case .snack: return Color(hex: "FCE7F3")
        case .dinner: return pulsePrimaryLight
        }
    }

    static func pulseMealAccent(for mealType: Meal.MealType) -> Color {
        switch mealType {
        case .breakfast: return pulseAmber
        case .lunch: return pulseMint
        case .snack: return Color(hex: "EC4899")
        case .dinner: return pulsePrimary
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
