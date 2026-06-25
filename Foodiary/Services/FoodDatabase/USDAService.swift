import Foundation

/// USDA FoodData Central API provider.
///
/// Free to use. Register at https://fdc.nal.usda.gov/api-key-signup.html for a key
/// (or use DEMO_KEY for 50 requests/day during development).
///
/// Endpoints used:
/// - `GET /foods/search?query=...&pageSize=N&api_key=...`
/// - `GET /food/{fdcId}?api_key=...`
struct USDAService: FoodDatabaseProvider {
    let source: FoodDatabaseSource = .usda

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    // MARK: - Search

    func search(query: String) async throws -> [FoodSearchResult] {
        guard FoodDatabaseConfig.isUSDAConfigured else {
            throw FoodDatabaseError.notConfigured(.usda)
        }

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }

        var components = URLComponents(string: "\(FoodDatabaseConfig.usdaBaseURL)/foods/search")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "pageSize", value: "25"),
            URLQueryItem(name: "dataType", value: "Foundation,SR Legacy,Survey (FNDDS),Branded"),
            URLQueryItem(name: "api_key", value: FoodDatabaseConfig.usdaAPIKey),
        ]

        guard let url = components.url else {
            throw FoodDatabaseError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        try validateResponse(response, data: data)

        let apiResponse: FoodSearchResult.USDASearchResponse
        do {
            apiResponse = try decoder.decode(FoodSearchResult.USDASearchResponse.self, from: data)
        } catch {
            throw FoodDatabaseError.parseError("USDA search: \(error.localizedDescription)")
        }

        return (apiResponse.foods ?? []).map { FoodSearchResult.fromUSDA($0) }
    }

    // MARK: - Get Details

    func getDetails(externalID: String) async throws -> FoodSearchResult {
        guard FoodDatabaseConfig.isUSDAConfigured else {
            throw FoodDatabaseError.notConfigured(.usda)
        }

        // USDA food detail endpoint: GET /food/{fdcId}
        var components = URLComponents(string: "\(FoodDatabaseConfig.usdaBaseURL)/food/\(externalID)")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: FoodDatabaseConfig.usdaAPIKey),
        ]

        guard let url = components.url else {
            throw FoodDatabaseError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        try validateResponse(response, data: data)

        // The detail endpoint returns the same USDAFood shape
        let food: FoodSearchResult.USDASearchResponse.USDAFood
        do {
            food = try decoder.decode(FoodSearchResult.USDASearchResponse.USDAFood.self, from: data)
        } catch {
            throw FoodDatabaseError.parseError("USDA detail: \(error.localizedDescription)")
        }

        return FoodSearchResult.fromUSDA(food)
    }

    // MARK: - Helpers

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw FoodDatabaseError.networkError(
                NSError(domain: "USDAService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            )
        }

        switch http.statusCode {
        case 200:
            return
        case 429:
            let retry = http.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init)
            throw FoodDatabaseError.rateLimited(retryAfter: retry)
        case 401, 403:
            throw FoodDatabaseError.unauthorized("USDA API key is invalid or expired (HTTP \(http.statusCode)).")
        case 404:
            throw FoodDatabaseError.notFound
        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw FoodDatabaseError.networkError(
                NSError(domain: "USDAService", code: http.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body.prefix(200))"])
            )
        }
    }
}

// MARK: - Raw API Response Models

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

// MARK: - Helpers

private extension Double {
    var cleanFormatted: String {
        truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", self)
            : String(self)
    }
}
