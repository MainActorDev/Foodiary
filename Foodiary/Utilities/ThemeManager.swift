import SwiftUI

// MARK: - App Theme Preference

/// User-selectable appearance preference.
/// Stored in UserDefaults as a raw string so it survives app restarts.
enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var displayName: String {
        switch self {
        case .system: return L10n["settings.theme.system"]
        case .light:  return L10n["settings.theme.light"]
        case .dark:   return L10n["settings.theme.dark"]
        }
    }

    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
}

// MARK: - Theme Manager

/// Observable appearance manager.
/// Observed at the app root to drive `.preferredColorScheme`.
@MainActor
final class ThemeManager: ObservableObject {
    @Published var selectedTheme: AppTheme

    static let shared = ThemeManager()
    static let defaultsKey = "app_theme_preference"

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.defaultsKey),
           let theme = AppTheme(rawValue: raw) {
            selectedTheme = theme
        } else {
            selectedTheme = .system
        }
    }

    func switchTo(_ theme: AppTheme) {
        selectedTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: Self.defaultsKey)
    }
}
