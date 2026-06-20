import Foundation

// MARK: - Thread-safe language storage

/// Nonisolated storage for the current app language.
/// Written by the main actor at bootstrap time, read by Bundle overrides on any thread.
enum AppLanguage {
    nonisolated(unsafe) static var current: String = "id"

    static let defaultsKey = "app_locale_preference"
}

// MARK: - Locale Manager

/// Manages runtime language preference for the app.
///
/// On first launch, defaults to Indonesian ("id") regardless of device locale.
/// Call `LocaleManager.bootstrap()` from `FoodiaryApp.init()` before any views render.
@MainActor
final class LocaleManager: ObservableObject {
    @Published var selectedLanguage: String

    static let shared = LocaleManager()

    private init() {
        if let stored = UserDefaults.standard.string(forKey: AppLanguage.defaultsKey), !stored.isEmpty {
            selectedLanguage = stored
        } else {
            selectedLanguage = "id"
        }
        AppLanguage.current = selectedLanguage
    }

    /// Must be called before any `String(localized:)` or `Text(L10n[...])` call.
    static func bootstrap() {
        let lang = UserDefaults.standard.string(forKey: AppLanguage.defaultsKey) ?? "id"
        UserDefaults.standard.set(lang, forKey: AppLanguage.defaultsKey)
        UserDefaults.standard.set([lang], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        AppLanguage.current = lang

        // Redirect Bundle.main's localizedString calls to our language-specific lproj.
        object_setClass(Bundle.main, LocalizedBundle.self)
    }

    /// Switches language at runtime. Views need a re-render to pick up changes.
    func switchTo(_ language: String) {
        guard language != selectedLanguage else { return }
        selectedLanguage = language
        AppLanguage.current = language
        UserDefaults.standard.set(language, forKey: AppLanguage.defaultsKey)
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    func resetToDefault() {
        switchTo("id")
    }
}

// MARK: - Bundle subclass for runtime language override

private final class LocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let lang = AppLanguage.current
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
              let langBundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return langBundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
