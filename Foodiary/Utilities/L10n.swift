import Foundation
import SwiftUI

/// Thread-safe localization lookup.
///
/// Reads the current language from the `LocaleManager` and returns the
/// matching localized string from the language-specific `.lproj` bundle.
///
/// The resolved `Bundle` is cached per-language and rebuilt only when the
/// language changes — so repeated `L10n["key"]` calls during a render pass
/// are cheap.
///
/// **SwiftUI integration:** views must observe `LocaleManager` (directly or
/// via `.environmentObject`) so that a language change triggers a re-render
/// and `L10n` calls re-evaluate. Use the `\.localeManager` environment key
/// or `@ObservedObject`.
enum L10n {

    /// Default language if no preference has been saved yet.
    static let defaultLanguage = "id"

    static subscript(_ key: String) -> String {
        let lang = currentLanguage
        let bundle = resolvedBundle(for: lang)
        return bundle.localizedString(forKey: key, value: key, table: "Localizable")
    }

    static subscript(_ key: String, _ arguments: any CVarArg...) -> String {
        let format = self[key]
        return String(format: format, arguments: arguments)
    }

    // MARK: - Internals

    /// UserDefaults key for the saved language preference.
    nonisolated static let defaultsKey = "app_locale_preference"

    /// Returns the current language from UserDefaults.
    private static var currentLanguage: String {
        UserDefaults.standard.string(forKey: defaultsKey) ?? defaultLanguage
    }

    /// Cached bundles keyed by language code (e.g. "en", "id").
    nonisolated(unsafe) private static var bundleCache: [String: Bundle] = [:]
    private static let cacheLock = NSLock()

    /// Returns the lproj `Bundle` for the given language.
    /// Creates and caches it if needed; returns `Bundle.main` as fallback.
    private static func resolvedBundle(for lang: String) -> Bundle {
        cacheLock.lock()
        if let cached = bundleCache[lang] {
            cacheLock.unlock()
            return cached
        }
        cacheLock.unlock()

        let bundle: Bundle
        if let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
           let langBundle = Bundle(path: path) {
            bundle = langBundle
        } else {
            bundle = Bundle.main
        }

        cacheLock.lock()
        bundleCache[lang] = bundle
        cacheLock.unlock()

        return bundle
    }

    /// Clears the bundle cache. Call when the language changes.
    static func invalidateCache() {
        cacheLock.lock()
        bundleCache.removeAll()
        cacheLock.unlock()
    }
}

// MARK: - Environment Key

private struct LocaleManagerKey: EnvironmentKey {
    static let defaultValue: LocaleManager? = nil
}

extension EnvironmentValues {
    /// Access the `LocaleManager` from the environment.
    /// Inject at the app root: `.environmentObject(LocaleManager.shared)`
    var localeManager: LocaleManager? {
        get { self[LocaleManagerKey.self] }
        set { self[LocaleManagerKey.self] = newValue }
    }
}
