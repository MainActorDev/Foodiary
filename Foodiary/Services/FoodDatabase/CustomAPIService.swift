import Foundation

/// Placeholder provider for Foodiary's own fallback food database API.
///
/// This is a stub — the actual API is not yet developed. When ready:
/// 1. Implement `search(query:)` against your API endpoint
/// 2. Implement `getDetails(externalID:)` for full nutrition data
/// 3. Map your API's response into `FoodSearchResult` (add response models below)
/// 4. Update `FoodDatabaseConfig` with your API credentials
///
/// The provider is automatically activated when credentials are configured
/// in the xcconfig file (CUSTOM_API_BASE_URL must be non-empty).
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

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }

        // TODO: Implement when the custom API is built.
        // Example:
        //   let url = URL(string: "\(FoodDatabaseConfig.customAPIBaseURL)/search?q=\(query)")!
        //   var request = URLRequest(url: url)
        //   request.setValue("Bearer \(FoodDatabaseConfig.customAPIToken)", forHTTPHeaderField: "Authorization")
        //   let (data, response) = try await session.data(for: request)
        //   // Parse and map to [FoodSearchResult]

        // For now, return empty — provider is a no-op until implemented.
        return []
    }

    // MARK: - Get Details

    func getDetails(externalID: String) async throws -> FoodSearchResult {
        guard FoodDatabaseConfig.isCustomAPIConfigured else {
            throw FoodDatabaseError.notConfigured(.custom)
        }

        // TODO: Implement when the custom API is built.
        throw FoodDatabaseError.notFound
    }
}

// MARK: - Response Models (add your API's Codable types here)

// TODO: Define Decodable structs for your custom API's response shape.
//
// Example:
//   extension FoodSearchResult {
//       struct CustomSearchResponse: Decodable { ... }
//       static func fromCustom(_ item: CustomSearchResponse.Item) -> FoodSearchResult { ... }
//   }
