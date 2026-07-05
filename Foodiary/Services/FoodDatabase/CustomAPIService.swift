import Foundation

/// Foodiary's own food database API at foodiary-api.anyapp.my.
///
/// Runs in parallel with FatSecret via FoodSearchService. Returns
/// FatSecret-compatible JSON so the same FoodSearchResult mapping
/// works for both providers.
struct CustomAPIService: FoodDatabaseProvider {
    let source: FoodDatabaseSource = .custom

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    // MARK: - Search

    func search(query: String) async throws -> [FoodSearchResult] {
        guard FoodDatabaseConfig.isCustomAPIConfigured else {
            throw FoodDatabaseError.notConfigured(.custom)
        }
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }

        var components = URLComponents(string: "\(FoodDatabaseConfig.customAPIBaseURL)/api/v1/foods/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: trimmed),
            URLQueryItem(name: "limit", value: "20")
        ]
        guard let url = components?.url else {
            throw FoodDatabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(FoodDatabaseConfig.customAPIToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)

        let parsed = try decoder.decode(FoodSearchResult.CustomSearchResponse.self, from: data)
        return (parsed.foods?.food ?? []).compactMap { FoodSearchResult.fromCustom($0) }
    }

    // MARK: - Get Details

    func getDetails(externalID: String) async throws -> FoodSearchResult {
        guard FoodDatabaseConfig.isCustomAPIConfigured else {
            throw FoodDatabaseError.notConfigured(.custom)
        }

        let urlString = "\(FoodDatabaseConfig.customAPIBaseURL)/api/v1/foods/\(externalID)"
        guard let url = URL(string: urlString) else {
            throw FoodDatabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(FoodDatabaseConfig.customAPIToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)

        let parsed = try decoder.decode(FoodSearchResult.CustomDetailResponse.self, from: data)
        return FoodSearchResult.fromCustomDetail(parsed.food)
    }

    // MARK: - Validation

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw FoodDatabaseError.networkError(NSError(domain: "CustomAPIService", code: -1))
        }
        guard (200...299).contains(http.statusCode) else {
            throw FoodDatabaseError.networkError(
                NSError(domain: "CustomAPIService", code: http.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
            )
        }
    }
}

// MARK: - Response Models

extension FoodSearchResult {
    /// Search response — FatSecret-compatible shape from the custom API.
    struct CustomSearchResponse: Decodable {
        let foods: FoodsContainer?

        struct FoodsContainer: Decodable {
            let food: [CustomFoodSummary]?
        }
    }

    struct CustomFoodSummary: Decodable {
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

    /// Detail response — FatSecret-compatible shape with full serving data.
    struct CustomDetailResponse: Decodable {
        let food: CustomFoodDetail?
    }

    struct CustomFoodDetail: Decodable {
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

        struct ServingsContainer: Decodable {
            let serving: [CustomServing]?
        }

        struct CustomServing: Decodable {
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

    // MARK: - Mappers

    /// Map a custom API search result to FoodSearchResult.
    /// Parses nutrients from the food_description string using the same
    /// two-pass regex approach as FatSecretService.
    static func fromCustom(_ food: CustomFoodSummary) -> FoodSearchResult? {
        guard let name = food.foodName, !name.isEmpty else { return nil }
        let parsed = parseCustomNutrients(from: food.foodDescription)
        return FoodSearchResult(
            id: compositeID(source: .custom, externalID: food.foodId ?? ""),
            name: name,
            brand: food.brandName,
            calories: parsed.calories,
            protein: parsed.protein,
            carbs: parsed.carbs,
            fat: parsed.fat,
            servingDescription: parsed.servingDescription,
            source: .custom
        )
    }

    /// Map a custom API detail response to FoodSearchResult.
    static func fromCustomDetail(_ food: CustomFoodDetail?) -> FoodSearchResult {
        let serving = food?.servings?.serving?.first
        return FoodSearchResult(
            id: compositeID(source: .custom, externalID: food?.foodId ?? ""),
            name: food?.foodName ?? "Unknown",
            brand: food?.brandName,
            calories: Int(round(Double(serving?.calories ?? "0") ?? 0)),
            protein: Int(round(Double(serving?.protein ?? "0") ?? 0)),
            carbs: Int(round(Double(serving?.carbohydrate ?? "0") ?? 0)),
            fat: Int(round(Double(serving?.fat ?? "0") ?? 0)),
            servingDescription: serving?.servingDescription,
            source: .custom
        )
    }

    // MARK: - Nutrient Parsing

    /// Parse nutrients from food_description string.
    /// Format: "Per 1 piring (250g) - Calories: 450kcal | Fat: 13g | Carbs: 70g | Protein: 11.3g"
    ///
    /// Uses two-pass regex extraction (outer match → inner digit extraction),
    /// identical to FatSecretService.parseNutrientsFromDescription.
    private static func parseCustomNutrients(from description: String?) -> (
        calories: Int, protein: Int, carbs: Int, fat: Int, servingDescription: String?
    ) {
        guard let desc = description else {
            return (0, 0, 0, 0, nil)
        }

        // Extract serving description (text before " - ")
        var servingDesc: String? = nil
        if let dashRange = desc.range(of: " - ") {
            servingDesc = String(desc[..<dashRange.lowerBound])
        }

        /// Outer regex finds the nutrient segment, inner regex extracts the number.
        func extract(pattern: String) -> Int {
            guard let match = desc.range(of: pattern, options: .regularExpression) else { return 0 }
            let matched = String(desc[match])
            guard let valueMatch = matched.range(of: #"[0-9.]+"#, options: .regularExpression) else { return 0 }
            return Int(round(Double(String(matched[valueMatch])) ?? 0))
        }

        return (
            calories: extract(pattern: #"Calories:\s*\d+\.?\d*\s*kcal"#),
            protein: extract(pattern: #"Protein:\s*\d+\.?\d*\s*g"#),
            carbs: extract(pattern: #"Carbs:\s*\d+\.?\d*\s*g"#),
            fat: extract(pattern: #"Fat:\s*\d+\.?\d*\s*g"#),
            servingDescription: servingDesc
        )
    }
}
