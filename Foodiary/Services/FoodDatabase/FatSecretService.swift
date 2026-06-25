import Foundation

/// FatSecret Platform API provider — OAuth 1.0 HMAC-SHA1.
///
/// Free Basic tier. Register at https://platform.fatsecret.com/register.
/// Get Consumer Key + Secret from the developer dashboard.
///
/// Endpoints used (all via `platform.fatsecret.com/rest/server.api`):
/// - `foods.search` — search foods by keyword
/// - `food.get` — detailed nutrition for a food by ID
struct FatSecretService: FoodDatabaseProvider {
    let source: FoodDatabaseSource = .fatsecret

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    private var isConfigured: Bool {
        FoodDatabaseConfig.isFatSecretConfigured
    }

    private var consumerKey: String {
        FoodDatabaseConfig.fatSecretConsumerKey
    }

    private var consumerSecret: String {
        FoodDatabaseConfig.fatSecretConsumerSecret
    }

    // MARK: - Search

    func search(query: String) async throws -> [FoodSearchResult] {
        guard isConfigured else {
            throw FoodDatabaseError.notConfigured(.fatsecret)
        }
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }

        let data = try await signedRequest(params: [
            "method": "foods.search",
            "search_expression": query,
            "max_results": "25",
            "format": "json",
        ])

        let apiResponse: FoodSearchResult.FatSecretSearchResponse
        do {
            apiResponse = try decoder.decode(FoodSearchResult.FatSecretSearchResponse.self, from: data)
        } catch {
            throw FoodDatabaseError.parseError("FatSecret search: \(error.localizedDescription)")
        }

        let foods = apiResponse.foods?.food ?? []
        return foods.map { FoodSearchResult.fromFatSecretSummary($0) }
    }

    // MARK: - Get Details

    func getDetails(externalID: String) async throws -> FoodSearchResult {
        guard isConfigured else {
            throw FoodDatabaseError.notConfigured(.fatsecret)
        }

        let data = try await signedRequest(params: [
            "method": "food.get",
            "food_id": externalID,
            "format": "json",
        ])

        let apiResponse: FoodSearchResult.FatSecretGetResponse
        do {
            apiResponse = try decoder.decode(FoodSearchResult.FatSecretGetResponse.self, from: data)
        } catch {
            throw FoodDatabaseError.parseError("FatSecret detail: \(error.localizedDescription)")
        }

        guard let food = apiResponse.food else {
            throw FoodDatabaseError.notFound
        }

        let primaryServing = food.servings?.serving?.first

        let summary = FoodSearchResult.FatSecretSearchResponse.FatSecretFoodSummary(
            foodId: food.foodId,
            foodName: food.foodName,
            brandName: food.brandName,
            foodDescription: primaryServing?.servingDescription
        )

        return FoodSearchResult.fromFatSecretSummary(summary, withNutrients: primaryServing)
    }

    // MARK: - Request Signing & Execution

    private func signedRequest(params: [String: String]) async throws -> Data {
        let oauthParams = FatSecretOAuth.sign(
            httpMethod: "GET",
            baseURL: FoodDatabaseConfig.fatSecretBaseURL,
            parameters: params,
            consumerKey: consumerKey,
            consumerSecret: consumerSecret
        )

        // Build Authorization header
        let authHeader = "OAuth " + oauthParams
            .sorted(by: { $0.key < $1.key })
            .map { "\($0.key.oauthHeaderEncoded)=\"\($0.value.oauthHeaderEncoded)\"" }
            .joined(separator: ", ")

        // Build URL with method params in query string
        var components = URLComponents(string: FoodDatabaseConfig.fatSecretBaseURL)!
        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components.url else {
            throw FoodDatabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        return data
    }

    // MARK: - Response Validation

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw FoodDatabaseError.networkError(NSError(domain: "FatSecretService", code: -1))
        }

        switch http.statusCode {
        case 200:
            // Check for API-level errors in JSON body
            if let err = try? decoder.decode(FatSecretErrorResponse.self, from: data), let error = err.error {
                switch error.code {
                case 5:  throw FoodDatabaseError.rateLimited(retryAfter: nil)
                case 8:  throw FoodDatabaseError.unauthorized("FatSecret: invalid signature — check consumer key/secret.")
                case 21: throw FoodDatabaseError.unauthorized("FatSecret: IP not whitelisted. Add this IP in your developer dashboard.")
                default: throw FoodDatabaseError.unauthorized(error.message ?? "API error code \(error.code ?? 0)")
                }
            }
            return
        case 429:
            let retry = http.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init)
            throw FoodDatabaseError.rateLimited(retryAfter: retry)
        case 401, 403:
            throw FoodDatabaseError.unauthorized("FatSecret: unauthorized (HTTP \(http.statusCode)).")
        case 404:
            throw FoodDatabaseError.notFound
        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw FoodDatabaseError.networkError(
                NSError(domain: "FatSecretService", code: http.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body.prefix(200))"])
            )
        }
    }
}

// MARK: - Internal Response Models

private struct FatSecretErrorResponse: Decodable {
    struct FatSecretError: Decodable {
        let code: Int?
        let message: String?
    }
    let error: FatSecretError?
}

// MARK: - OAuth Header Encoding

private extension String {
    var oauthHeaderEncoded: String {
        let unreserved = CharacterSet(
            charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
        )
        return addingPercentEncoding(withAllowedCharacters: unreserved) ?? self
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

    static func fromFatSecretSummary(
        _ food: FatSecretSearchResponse.FatSecretFoodSummary,
        withNutrients nutrients: FatSecretGetResponse.FatSecretServing? = nil
    ) -> FoodSearchResult {
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

    private static func parseNutrientsFromDescription(
        _ description: String?
    ) -> FatSecretGetResponse.FatSecretServing? {
        guard let desc = description else { return nil }
        var servingDesc: String?
        if let dashRange = desc.range(of: " - ") {
            servingDesc = String(desc[..<dashRange.lowerBound])
        }
        func extractValue(pattern: String) -> String? {
            guard let match = desc.range(of: pattern, options: .regularExpression) else { return nil }
            let matched = String(desc[match])
            guard let valueMatch = matched.range(of: #"[\d.]+"#, options: .regularExpression) else { return nil }
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
