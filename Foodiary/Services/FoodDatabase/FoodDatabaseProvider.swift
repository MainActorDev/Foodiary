import Foundation

// MARK: - Errors

/// Errors that can occur during food database operations.
enum FoodDatabaseError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case rateLimited(retryAfter: TimeInterval?)
    case unauthorized(String)
    case notFound
    case parseError(String)
    case notConfigured(FoodDatabaseSource)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimited(let retry):
            if let retry = retry {
                return "Rate limited. Retry after \(Int(retry)) seconds."
            }
            return "Too many requests. Please wait before trying again."
        case .unauthorized(let msg):
            return "API authentication failed: \(msg)"
        case .notFound:
            return "Food not found."
        case .parseError(let msg):
            return "Failed to parse API response: \(msg)"
        case .notConfigured(let source):
            return "\(source.sourceDisplayName) is not configured. Add API credentials in FoodDatabaseConfig."
        }
    }
}

// MARK: - Protocol

/// A food database provider that can search for foods and retrieve detailed nutrition.
///
/// Implement this protocol to add a new food data source (USDA, FatSecret, Open Food Facts, etc.).
/// The `FoodSearchService` facade queries all registered providers.
protocol FoodDatabaseProvider: Sendable {
    /// Which database this provider represents.
    var source: FoodDatabaseSource { get }

    /// Search for foods matching a text query.
    /// - Parameter query: The search text (e.g., "banana", "chicken breast").
    /// - Returns: An array of unified search results, best matches first.
    func search(query: String) async throws -> [FoodSearchResult]

    /// Get detailed nutrition for a specific food by its provider-specific ID (not composite ID).
    /// - Parameter externalID: The provider's own ID for the food (e.g., "454004" for USDA, "12345" for FatSecret).
    /// - Returns: A fully populated search result with all nutrient fields.
    func getDetails(externalID: String) async throws -> FoodSearchResult
}

// MARK: - Provider priority

/// Defines the order in which providers are queried and how results are merged.
enum ProviderPriority: Int, Comparable {
    case primary = 0
    case secondary = 1
    case fallback = 2

    static func < (lhs: ProviderPriority, rhs: ProviderPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension FoodDatabaseSource {
    /// Display name for UI attribution.
    var sourceDisplayName: String {
        switch self {
        case .fatsecret: return "FatSecret"
        case .custom: return "Foodiary"
        case .usda: return "USDA"
        case .openFoodFacts: return "Open Food Facts"
        }
    }
}
