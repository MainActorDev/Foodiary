import Foundation

/// Which food database a result came from.
enum FoodDatabaseSource: String, Codable, CaseIterable {
    case fatsecret     // Primary — FatSecret Basic API (free tier)
    case custom        // Fallback — our own API (not yet built)
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
    /// The caller is responsible for inserting the item into the model context.
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

// MARK: - Raw API Response Models (USDA)

extension FoodSearchResult {
    /// Decodable wrapper for the USDA /foods/search endpoint.
    struct USDASearchResponse: Decodable {
        let totalHits: Int?
        let foods: [USDAFood]?

        struct USDAFood: Decodable {
            let fdcId: Int
            let description: String?
            let brandOwner: String?
            let servingSize: Double?
            let servingSizeUnit: String?
            let householdServingFullText: String?
            let foodNutrients: [USDANutrient]?

            struct USDANutrient: Decodable {
                let nutrientName: String?
                let value: Double?
            }
        }
    }

    /// Map a USDA food item into a unified FoodSearchResult.
    static func fromUSDA(_ food: USDASearchResponse.USDAFood) -> FoodSearchResult {
        let nutrients = food.foodNutrients ?? []
        let nutrientMap = Dictionary(
            uniqueKeysWithValues: nutrients.compactMap { n in
                n.nutrientName.map { ($0, n.value ?? 0) }
            }
        )

        let serving: String? = {
            if let text = food.householdServingFullText, !text.isEmpty { return text }
            guard let size = food.servingSize, let unit = food.servingSizeUnit else { return nil }
            return "\(size.cleanFormatted) \(unit)"
        }()

        return FoodSearchResult(
            id: compositeID(source: .usda, externalID: String(food.fdcId)),
            name: food.description ?? "Unknown",
            brand: food.brandOwner,
            calories: Int(round(nutrientMap["Energy"] ?? 0)),
            protein: Int(round(nutrientMap["Protein"] ?? 0)),
            carbs: Int(round(nutrientMap["Carbohydrate, by difference"] ?? 0)),
            fat: Int(round(nutrientMap["Total lipid (fat)"] ?? 0)),
            servingDescription: serving,
            source: .usda
        )
    }
}

// MARK: - Raw API Response Models (FatSecret)

extension FoodSearchResult {
    /// Decodable wrapper for FatSecret food.search response.
    struct FatSecretSearchResponse: Decodable {
        let foods: FoodsContainer?

        struct FoodsContainer: Decodable {
            let food: [FatSecretFoodSummary]?
        }

        struct FatSecretFoodSummary: Decodable {
            let foodId: String?
            let foodName: String?
            let brandName: String?
            let foodDescription: String?

            enum CodingKeys: String, CodingKey {
                case foodId = "food_id"
                case foodName = "food_name"
                case brandName = "brand_name"
                case foodDescription = "food_description"
            }
        }
    }

    /// Decodable wrapper for FatSecret food.get response.
    struct FatSecretGetResponse: Decodable {
        let food: FatSecretFoodDetail?

        struct FatSecretFoodDetail: Decodable {
            let foodId: String?
            let foodName: String?
            let brandName: String?
            let servings: ServingsContainer?

            enum CodingKeys: String, CodingKey {
                case foodId = "food_id"
                case foodName = "food_name"
                case brandName = "brand_name"
                case servings
            }
        }

        struct ServingsContainer: Decodable {
            let serving: [FatSecretServing]?
        }

        struct FatSecretServing: Decodable {
            let calories: String?
            let protein: String?
            let carbohydrate: String?
            let fat: String?
            let servingDescription: String?

            enum CodingKeys: String, CodingKey {
                case calories, protein, carbohydrate, fat
                case servingDescription = "serving_description"
            }
        }
    }

    /// Map a FatSecret search summary into a unified FoodSearchResult.
    /// The summary includes basic info; nutrients are parsed from the description
    /// or will be populated by a subsequent food.get call.
    static func fromFatSecretSummary(
        _ food: FatSecretSearchResponse.FatSecretFoodSummary,
        withNutrients nutrients: FatSecretGetResponse.FatSecretServing? = nil
    ) -> FoodSearchResult {
        // Try to parse nutrients from food_description (e.g., "Per 1 medium - Calories: 95kcal | Fat: 0.3g...")
        let parsed = nutrients ?? parseNutrientsFromDescription(food.foodDescription)

        let calStr = parsed?.calories ?? "0"
        let protStr = parsed?.protein ?? "0"
        let carbStr = parsed?.carbohydrate ?? "0"
        let fatStr = parsed?.fat ?? "0"

        return FoodSearchResult(
            id: compositeID(source: .fatsecret, externalID: food.foodId ?? ""),
            name: food.foodName ?? "Unknown",
            brand: food.brandName,
            calories: Int(round(Double(calStr) ?? 0)),
            protein: Int(round(Double(protStr) ?? 0)),
            carbs: Int(round(Double(carbStr) ?? 0)),
            fat: Int(round(Double(fatStr) ?? 0)),
            servingDescription: parsed?.servingDescription ?? food.foodDescription,
            source: .fatsecret
        )
    }

    /// Parse nutrients from FatSecret's food_description string.
    /// Format: "Per 1 medium - Calories: 95kcal | Fat: 0.3g | Carbs: 25g | Protein: 0.5g"
    private static func parseNutrientsFromDescription(
        _ description: String?
    ) -> FatSecretGetResponse.FatSecretServing? {
        guard let desc = description else { return nil }

        // Extract serving description (text before " - " or before "Calories:")
        var servingDesc: String?
        if let dashRange = desc.range(of: " - ") {
            servingDesc = String(desc[..<dashRange.lowerBound])
        }

        // Extract a numeric value from a regex pattern in the description.
        func extractValue(pattern: String) -> String? {
            guard let match = desc.range(of: pattern, options: .regularExpression) else {
                return nil
            }
            let matched = String(desc[match])
            guard let valueMatch = matched.range(of: #"[\d.]+"#, options: .regularExpression) else {
                return nil
            }
            return String(matched[valueMatch])
        }

        return FatSecretGetResponse.FatSecretServing(
            calories: extractValue(pattern: #"Calories:\s*([\d.]+)\s*kcal"#),
            protein: extractValue(pattern: #"Protein:\s*([\d.]+)\s*g"#),
            carbohydrate: extractValue(pattern: #"Carbs:\s*([\d.]+)\s*g"#),
            fat: extractValue(pattern: #"Fat:\s*([\d.]+)\s*g"#),
            servingDescription: servingDesc
        )
    }
}

// MARK: - Helpers

private extension Double {
    /// Format a Double without trailing zeros (e.g., 154.0 → "154").
    var cleanFormatted: String {
        truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", self)
            : String(self)
    }
}
