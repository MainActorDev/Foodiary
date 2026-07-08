import Foundation

/// Facade that queries the configured food database provider(s) and merges results.
///
/// **Active provider:** Custom API (foodiary-api.anyapp.my) — sole source.
/// **Detached:** FatSecret (code preserved, endpoint no longer called).
/// **Deactivated:** USDA (code preserved).
///
/// Usage:
/// ```swift
/// let results = try await FoodSearchService.search(query: "chicken breast")
/// // results are deduplicated, sorted by relevance, with primary source first
/// ```
///
/// To get full nutrition details for a result:
/// ```swift
/// let detail = try await FoodSearchService.getDetails(for: results[0])
/// ```
///
/// To add or reorder providers, edit `allProviders` below.
enum FoodSearchService {
    /// Registered providers, in priority order (first = primary).
    /// Only configured providers are queried. To deactivate a provider,
    /// leave its credentials empty in xcconfig.
    private static let allProviders: [any FoodDatabaseProvider] = [
        CustomAPIService(),      // Primary — our own API (foodiary-api.anyapp.my)
        // FatSecretService(),  // Detached 2026-07-08 — code preserved at FoodDatabase/FatSecretService.swift
        // USDAService(),        // Deactivated — code preserved at FoodDatabase/USDAService.swift
    ]

    /// Active providers (those with valid credentials).
    private static var activeProviders: [any FoodDatabaseProvider] {
        allProviders.filter { provider in
            switch provider.source {
            case .fatsecret:
                return false // Detached 2026-07-08 — code preserved, endpoint no longer queried
            case .custom:
                return FoodDatabaseConfig.isCustomAPIConfigured
            case .usda:
                return false // Deactivated per 2026-06-21 decision
            case .openFoodFacts:
                return false // Not yet implemented
            }
        }
    }

    // MARK: - Search

    /// Search across all configured food databases.
    ///
    /// Queries all active providers in parallel and merges results.
    /// Results are deduplicated by name and sorted by source priority.
    ///
    /// - Parameter query: The search text (e.g., "banana", "nasi goreng").
    /// - Returns: Unified, deduplicated search results, primary source first.
    /// - Throws: `FoodDatabaseError` if all providers failed or none are configured.
    static func search(query: String) async throws -> [FoodSearchResult] {
        let providers = activeProviders

        guard !providers.isEmpty else {
            throw FoodDatabaseError.notConfigured(.custom)
        }

        // Query all providers in parallel
        let results = await withTaskGroup(
            of: (source: FoodDatabaseSource, results: [FoodSearchResult]).self
        ) { group in
            for provider in providers {
                group.addTask {
                    do {
                        let items = try await provider.search(query: query)
                        return (provider.source, items)
                    } catch {
                        print("[FoodSearchService] \(provider.source.sourceDisplayName) search failed: \(error.localizedDescription)")
                        return (provider.source, [])
                    }
                }
            }

            var allResults: [(source: FoodDatabaseSource, results: [FoodSearchResult])] = []
            for await result in group {
                allResults.append(result)
            }
            return allResults
        }

        // Merge: interleave by source priority, deduplicate by name
        return mergeResults(results)
    }

    // MARK: - Get Details

    /// Fetch full nutrition details for a search result from its source provider.
    ///
    /// The composite ID (e.g., "fatsecret:12345") encodes which provider to use.
    ///
    /// - Parameter result: A search result returned by `search(query:)`.
    /// - Returns: A fully populated result with all nutrient fields.
    /// - Throws: `FoodDatabaseError` if the provider fails or the food is not found.
    static func getDetails(for result: FoodSearchResult) async throws -> FoodSearchResult {
        let provider = activeProviders.first { $0.source == result.source }

        guard let provider = provider else {
            throw FoodDatabaseError.notConfigured(result.source)
        }

        return try await provider.getDetails(externalID: result.externalID)
    }

    // MARK: - Status

    /// Which sources are currently available.
    static var availableSources: [FoodDatabaseSource] {
        activeProviders.map(\.source)
    }

    /// Human-readable list of available sources.
    static var availableSourcesDescription: String {
        let names = availableSources.map(\.sourceDisplayName)
        return names.isEmpty ? "None" : names.joined(separator: ", ")
    }

    // MARK: - Result Merging

    /// Merge results from multiple providers: deduplicate by normalized name, interleave by priority.
    private static func mergeResults(
        _ providerResults: [(source: FoodDatabaseSource, results: [FoodSearchResult])]
    ) -> [FoodSearchResult] {
        // Priority order: Custom (primary) → FatSecret → (inactive sources last)
        let priorityOrder: [FoodDatabaseSource] = [.custom, .fatsecret, .usda, .openFoodFacts]
        let sorted = providerResults.sorted { a, b in
            let ap = priorityOrder.firstIndex(of: a.source) ?? 999
            let bp = priorityOrder.firstIndex(of: b.source) ?? 999
            return ap < bp
        }

        var seen = Set<String>()
        var merged: [FoodSearchResult] = []

        for (_, results) in sorted {
            for result in results {
                let normalized = result.name.lowercased().trimmingCharacters(in: .whitespaces)
                if seen.insert(normalized).inserted {
                    merged.append(result)
                }
            }
        }

        return merged
    }
}
