import Foundation

/// Which food database a result came from.
enum FoodDatabaseSource: String, Codable, CaseIterable {
    case fatsecret     // Primary — FatSecret Basic API (free tier)
    case custom        // Fallback — our own API
    case usda          // USDA FoodData Central (deactivated, code preserved)
    case openFoodFacts // Open Food Facts (not yet implemented)
}

/// A unified, provider-agnostic food search result.
/// Maps nutrition data from any API into Foodiary's domain model.
struct FoodSearchResult: Identifiable, Hashable, Sendable {
    /// Composite ID: "usda:454004" or "fatsecret:12345"
    let id: String
    /// Food name (e.g., "Apple", "Chicken Breast")
    let name: String
    /// Brand or manufacturer, if available
    let brand: String?
    /// Calories per serving
    let calories: Int
    /// Protein per serving (grams)
    let protein: Int
    /// Carbohydrates per serving (grams)
    let carbs: Int
    /// Fat per serving (grams)
    let fat: Int
    /// Human-readable serving description (e.g., "1 medium (182g)")
    let servingDescription: String?
    /// Which database this result came from
    let source: FoodDatabaseSource

    // MARK: - Convenience

    /// Build the composite ID for a given source and external ID.
    static func compositeID(source: FoodDatabaseSource, externalID: String) -> String {
        "\(source.rawValue):\(externalID)"
    }

    /// Extract the external ID from a composite ID.
    var externalID: String {
        String(id.split(separator: ":", maxSplits: 1).last ?? "")
    }

    /// Source display name for UI attribution.
    var sourceDisplayName: String {
        switch source {
        case .fatsecret: return "FatSecret"
        case .custom: return "Foodiary"
        case .usda: return "USDA"
        case .openFoodFacts: return "Open Food Facts"
        }
    }

    /// Convert this search result into a FoodItem suitable for saving to a meal plan.
    func toFoodItem() -> FoodItem {
        FoodItem(
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            note: sourceDisplayName
        )
    }
}
