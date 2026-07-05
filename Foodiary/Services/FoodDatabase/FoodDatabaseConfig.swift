import Foundation

/// Centralized configuration for food database API credentials.
///
/// Values are injected at build time from `Configuration/*.xcconfig` → Info.plist,
/// then read via Bundle.main. To change keys:
///
/// 1. Edit `Configuration/Debug.xcconfig` (for debug builds) or
///    `Configuration/Release.xcconfig` (for release builds)
/// 2. Rebuild — the new values flow through Info.plist automatically
///
/// **FatSecret** — Primary source. Register at https://platform.fatsecret.com/register
///   Free Basic tier. Fill in Consumer Key + Secret from the developer dashboard.
///
/// **Custom API** — Parallel provider (foodiary-api.anyapp.my).
/// Runs alongside FatSecret via FoodSearchService.
///
/// **USDA** — Deactivated per 2026-06-21 decision. Code preserved for reference.
enum FoodDatabaseConfig {
    // MARK: - FatSecret (Primary)

    /// FatSecret OAuth 1.0 Consumer Key.
    /// Set in Configuration/Debug.xcconfig or Configuration/Release.xcconfig.
    static var fatSecretConsumerKey: String {
        infoPlistValue("FATSECRET_CONSUMER_KEY")
    }

    /// FatSecret OAuth 1.0 Consumer Secret.
    static var fatSecretConsumerSecret: String {
        infoPlistValue("FATSECRET_CONSUMER_SECRET")
    }

    /// FatSecret API base URL (OAuth 1.0 endpoint).
    static let fatSecretBaseURL = "https://platform.fatsecret.com/rest/server.api"

    static var isFatSecretConfigured: Bool {
        !fatSecretConsumerKey.isEmpty && !fatSecretConsumerSecret.isEmpty
    }

    // MARK: - Custom API (Parallel provider — foodiary-api.anyapp.my)

    /// Base URL for our own fallback food database API.
    /// Set in Configuration/*.xcconfig.
    static var customAPIBaseURL: String {
        infoPlistValue("CUSTOM_API_BASE_URL")
    }

    /// Auth token for the custom API (if needed).
    /// Set in Configuration/*.xcconfig.
    static var customAPIToken: String {
        infoPlistValue("CUSTOM_API_TOKEN")
    }

    static var isCustomAPIConfigured: Bool {
        !customAPIBaseURL.isEmpty
    }

    // MARK: - USDA (Deactivated — preserved for reference)

    /// USDA FoodData Central API key.
    /// Code preserved at FoodDatabase/USDAService.swift. Deactivated in provider list.
    static var usdaAPIKey: String {
        infoPlistValue("USDA_API_KEY")
    }

    /// USDA API base URL.
    static let usdaBaseURL = "https://api.nal.usda.gov/fdc/v1"

    static var isUSDAConfigured: Bool {
        false // Deactivated per 2026-06-21 decision
    }

    // MARK: - Private

    /// Read a value from Info.plist, which is populated from .xcconfig build settings.
    private static func infoPlistValue(_ key: String) -> String {
        (Bundle.main.object(forInfoDictionaryKey: key) as? String) ?? ""
    }
}
