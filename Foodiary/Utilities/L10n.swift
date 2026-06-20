import Foundation

/// Type-safe wrapper around the Localizable.xcstrings String Catalog.
/// Use `L10n.key` to access localized strings. The catalog provides
/// English source strings and Indonesian translations.
enum L10n {
    /// Returns the localized string for `key` from the Localizable table.
    /// Uses the app's runtime language preference (set by `LocaleManager`).
    static subscript(_ key: String) -> String {
        String(localized: String.LocalizationValue(key), table: "Localizable")
    }

    /// Returns a localized string with the given format arguments.
    /// Uses the same runtime language preference as `subscript(_:)`.
    static subscript(_ key: String, _ arguments: any CVarArg...) -> String {
        let format = String(localized: String.LocalizationValue(key), table: "Localizable")
        return String(format: format, arguments: arguments)
    }
}
