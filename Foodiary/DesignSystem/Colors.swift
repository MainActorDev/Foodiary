import SwiftUI
import UIKit

// MARK: - Pulse v2 / Calorie Ring Design Colors

/// All color tokens resolve dynamically based on the current
/// `UITraitCollection.userInterfaceStyle` (light / dark).
///
/// No call-site changes needed — every `FoodiaryDesign.pulseBackground`
/// etc. automatically renders its dark variant when the app is in dark mode.
enum FoodiaryDesign {

    // Pulse v2 tokens — clean, modern planning cockpit
    static let pulseBackground = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "0C0C14") : UIColor(hex: "F6F7FF")
    })
    static let pulseBackgroundAlt = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "0F0F1A") : UIColor(hex: "F8FAFF")
    })
    static let pulseSurface = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "1A1A2E") : UIColor(hex: "FFFFFF")
    })
    static let pulseSurfaceSoft = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "222238") : UIColor(hex: "EEF0FF")
    })
    static let pulseSurfaceMint = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "0D2A22") : UIColor(hex: "E6FBF3")
    })
    static let pulsePrimary = Color(hex: "4BB8FA")
    static let pulsePrimaryLight = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "0D3A5C") : UIColor(hex: "DEF0FF")
    })
    static let pulsePrimaryDark = Color(hex: "0B4F8C")
    static let pulseMint = Color(hex: "10B981")
    static let pulseMintLight = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "0A3A2A") : UIColor(hex: "D1FAE5")
    })
    static let pulseCyan = Color(hex: "38BDF8")
    static let pulseCyanLight = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "0A2E3D") : UIColor(hex: "E0F6FF")
    })
    static let pulseAmber = Color(hex: "F59E0B")
    static let pulseAmberLight = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "3A2A08") : UIColor(hex: "FEF3C7")
    })
    static let pulseInk = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "F4F4F8") : UIColor(hex: "15142A")
    })
    /// Always-dark variant of pulseInk for inverted surfaces (action strip, etc.)
    /// that must stay dark in both light and dark mode.
    static let pulseInkFixed = Color(hex: "15142A")
    static let pulseMuted = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "8E8EA0") : UIColor(hex: "6B6880")
    })
    static let pulseBorder = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "2A2A40") : UIColor(hex: "C8C6D0")
    })
    static let pulseDivider = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "1E1E34") : UIColor(hex: "E8E6F0")
    })
    static let pulseDanger = Color(hex: "EF4444")
    static let pulseDangerLight = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "3A1414") : UIColor(hex: "FEE2E2")
    })

    // Day pill state colors
    static let pulseDayEmpty = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "2A1F08") : UIColor(hex: "FFF7ED")
    })
    static let pulseDayEmptyFg = Color(hex: "B45309")
    static let pulseDayFuture = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark ? UIColor(hex: "0A2A20") : UIColor(hex: "E6FBF3")
    })
    static let pulseDayFutureFg = Color(hex: "047857")
    static let pulseDayActiveFg = Color.white

    // Semantic helper tokens for shadows and strokes
    // (replaces hardcoded Color(hex:) scattered across view files)
    static var pulseShadow: Color { pulseInk }
    static var pulseStroke: Color { pulseInk }
    static var pulseCardShadow: Color { pulseInk.opacity(0.055) }
    static var pulseCardStroke: Color { pulseInk.opacity(0.10) }
    static var pulseAvatarGradient: LinearGradient {
        LinearGradient(colors: [pulsePrimary, Color(hex: "06B6D4")],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // Legacy palette (non-adaptive — used only in old onboarding)
    static let accent = Color(hex: "2563EB")
    static let accentLight = Color(hex: "DBEAFE")
    static let secondary = Color(hex: "059669")
    static let secondaryLight = Color(hex: "D1FAE5")
    static let warning = Color(hex: "D97706")
    static let warningLight = Color(hex: "FEF3C7")
    static let background = Color(hex: "F8FAFC")
    static let black = Color(hex: "0F172A")
    static let white = Color.white
    static let muted = Color(hex: "F1F5F9")
    static let mutedFg = Color(hex: "64748B")
    static let border = Color(hex: "CBD5E1")
    static let divider = Color(hex: "F1F5F9")

    // Legacy aliases
    static let coral = accent
    static let mint = secondary
    static let yellow = warning

    static func pulseMealTint(for mealType: Meal.MealType) -> Color {
        switch mealType {
        case .breakfast: return Color(UIColor { tc in
            tc.userInterfaceStyle == .dark ? UIColor(hex: "2A2410") : UIColor(hex: "FFF4D8")
        })
        case .lunch: return pulseMintLight
        case .snack: return Color(UIColor { tc in
            tc.userInterfaceStyle == .dark ? UIColor(hex: "2A1424") : UIColor(hex: "FCE7F3")
        })
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

// MARK: - UIColor hex convenience

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: 1
        )
    }
}

extension Color {
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
}
