import SwiftUI

/// Add Food flow — search-only with rich result cards.
///
/// Presents debounced search results as macro-detailed cards.
/// Tapping "Add" on a card calls `onSave` with the FoodItem.
/// Manual entry has been removed — search is the only path.
struct AddFoodItemView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    var onSave: (FoodItem) -> Void
    var onCancel: () -> Void

    @State private var searchQuery = ""
    @State private var searchResults: [FoodSearchResult] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var hasSearched = false
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 16) {
            searchBar

            Group {
                if isSearching {
                    skeletonList
                } else if let error = searchError {
                    errorView(error)
                } else if hasSearched && searchResults.isEmpty {
                    noResultsView
                } else if !searchResults.isEmpty {
                    resultsList
                } else {
                    emptyPrompt
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(FoodiaryDesign.pulseBackground)
        .navigationTitle(L10n["nav.add_food"])
        .navigationBarTitleDisplayMode(.inline)
        .pulseBackButton(action: onCancel)
        .onChange(of: searchQuery) { _, newValue in
            performSearch(query: newValue)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .font(.system(size: 16))
            TextField(L10n["add_food.search_placeholder"], text: $searchQuery)
                .font(.system(size: 15))
                .foregroundColor(FoodiaryDesign.pulseInk)
                .autocorrectionDisabled()
            if isSearching {
                ProgressView().scaleEffect(0.8)
            }
            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(FoodiaryDesign.pulseSurface))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1))
    }

    // MARK: - Results

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchResults) { result in
                    FoodResultCard(result: result, onAdd: {
                        onSave(result.toFoodItem())
                    })
                }
            }
        }
    }

    // MARK: - Skeleton Loading

    private var skeletonList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    FoodResultCardSkeleton()
                }
            }
        }
    }

    // MARK: - States

    private var emptyPrompt: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 60)
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(FoodiaryDesign.pulseMuted)
            Text(L10n["add_food.search_prompt"])
                .font(.system(size: 14))
                .foregroundColor(FoodiaryDesign.pulseMuted)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var noResultsView: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 40)
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundColor(FoodiaryDesign.pulseMuted)
            Text(L10n["add_food.no_results"])
                .font(.system(size: 14))
                .foregroundColor(FoodiaryDesign.pulseMuted)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 40)
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 36))
                .foregroundColor(FoodiaryDesign.pulseDanger)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Search Logic

    private func performSearch(query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            searchResults = []
            searchError = nil
            hasSearched = false
            isSearching = false
            return
        }
        isSearching = true
        hasSearched = true
        searchError = nil
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            do {
                let results = try await FoodSearchService.search(query: trimmed)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    searchResults = []
                    isSearching = false
                    searchError = error.localizedDescription
                }
            }
        }
    }
}
