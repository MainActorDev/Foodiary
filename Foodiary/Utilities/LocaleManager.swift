import Foundation

// MARK: - Supported Language

/// A language the app can display.
///
/// Add new entries here when a new `.lproj` is created — the Settings UI
/// will pick them up automatically.
struct SupportedLanguage: Identifiable, Hashable {
    let code: String
    let flag: String

    /// Native name — always shown in the language's own form,
    /// not translated (matches iOS Settings → Language & Region).
    let nativeName: String

    var id: String { code }
}

// MARK: - Locale Manager

/// Manages runtime language preference.
///
/// - `@Published var selectedLanguage` triggers SwiftUI re-renders
///   when the user picks a different language in Settings.
/// - `bootstrap()` must be called once from `FoodiaryApp.init()` before
///   any view renders.
/// - `L10n` reads the current language from `UserDefaults` directly on each
///   lookup, so no `Bundle.main` class swizzling is needed.
@MainActor
final class LocaleManager: ObservableObject {
    @Published var selectedLanguage: String

    static let shared = LocaleManager()

    /// Languages the app supports, displayed in Settings.
    static let supportedLanguages: [SupportedLanguage] = [
        SupportedLanguage(code: "id", flag: "🇮🇩", nativeName: "Bahasa Indonesia"),
        SupportedLanguage(code: "en", flag: "🇬🇧", nativeName: "English"),
    ]

    private init() {
        selectedLanguage = UserDefaults.standard.string(forKey: L10n.defaultsKey) ?? L10n.defaultLanguage
    }

    /// One-time setup at app launch. Ensures a default is persisted.
    static func bootstrap() {
        let lang = UserDefaults.standard.string(forKey: L10n.defaultsKey) ?? L10n.defaultLanguage
        UserDefaults.standard.set(lang, forKey: L10n.defaultsKey)
    }

    /// Switches app language at runtime. Views observing `LocaleManager`
    /// will re-render and `L10n` will return newly-localized strings.
    func switchTo(_ language: String) {
        guard language != selectedLanguage else { return }
        selectedLanguage = language
        UserDefaults.standard.set(language, forKey: L10n.defaultsKey)
        L10n.invalidateCache()
    }
}
