import SwiftUI

// MARK: - Add Food Item (Search-First Flow)
///
/// Thin state router — delegates to `SearchFoodView` or `ManualFoodFormView`.

struct AddFoodItemView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    var onSave: (FoodItem) -> Void
    var onCancel: () -> Void

    enum ScreenState { case searching, manual }
    @State private var screenState: ScreenState = .searching

    // Search state
    @State private var searchQuery = ""
    @State private var searchResults: [FoodSearchResult] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var hasSearched = false
    @State private var searchTask: Task<Void, Never>?

    // Manual form state
    @State private var name = ""
    @State private var caloriesText = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatText = ""
    @State private var note = ""
    @State private var nameError = false
    @State private var caloriesError = false

    var body: some View {
        Group {
            switch screenState {
            case .searching:
                SearchFoodView(
                    searchQuery: $searchQuery,
                    searchResults: searchResults,
                    isSearching: isSearching,
                    hasSearched: hasSearched,
                    searchError: searchError,
                    onSelectResult: { result in
                        onSave(result.toFoodItem())
                    },
                    onManualAdd: { screenState = .manual }
                )
                .onChange(of: searchQuery) { _, newValue in
                    performSearch(query: newValue)
                }

            case .manual:
                ManualFoodFormView(
                    name: $name,
                    caloriesText: $caloriesText,
                    proteinText: $proteinText,
                    carbsText: $carbsText,
                    fatText: $fatText,
                    note: $note,
                    nameError: $nameError,
                    caloriesError: $caloriesError,
                    onSave: saveManualItem
                )
            }
        }
        .background(FoodiaryDesign.pulseBackground)
        .navigationTitle(L10n["nav.add_food"])
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                PulseToolbarButton(
                    icon: screenState == .manual ? "arrow.left" : "xmark",
                    fgColor: FoodiaryDesign.pulseMuted
                ) {
                    if screenState == .manual { screenState = .searching }
                    else { onCancel() }
                }
            }
        }
    }

    // MARK: - Search Logic

    private func performSearch(query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            searchResults = []; searchError = nil; hasSearched = false; isSearching = false
            return
        }
        isSearching = true; hasSearched = true; searchError = nil
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            do {
                let results = try await FoodSearchService.search(query: trimmed)
                guard !Task.isCancelled else { return }
                await MainActor.run { searchResults = results; isSearching = false }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run { searchResults = []; isSearching = false; searchError = error.localizedDescription }
            }
        }
    }

    // MARK: - Manual Save

    private func saveManualItem() {
        nameError = name.trimmingCharacters(in: .whitespaces).isEmpty
        caloriesError = false
        guard !nameError else { return }
        guard let calories = Int(caloriesText.trimmingCharacters(in: .whitespaces)), calories >= 0 else {
            caloriesError = true; return
        }
        let protein = Int(proteinText.trimmingCharacters(in: .whitespaces)) ?? 0
        let carbs = Int(carbsText.trimmingCharacters(in: .whitespaces)) ?? 0
        let fat = Int(fatText.trimmingCharacters(in: .whitespaces)) ?? 0
        let item = FoodItem(
            name: name.trimmingCharacters(in: .whitespaces),
            calories: calories, protein: max(0, protein),
            carbs: max(0, carbs), fat: max(0, fat),
            note: note.trimmingCharacters(in: .whitespaces)
        )
        onSave(item)
    }
}
