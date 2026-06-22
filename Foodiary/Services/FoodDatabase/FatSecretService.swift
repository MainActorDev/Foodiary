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
