import SwiftUI

// MARK: - Add Food Item (Search-First Flow)
///
/// Two-phase screen for adding a food item to a meal:
/// 1. **Search** — user types a query; matching results appear.
///    Tapping a result immediately saves and dismisses the screen.
/// 2. **Manual** — fallback form shown when search yields no results
///    and the user taps "Add Manually".

struct AddFoodItemView: View {
    var onSave: (FoodItem) -> Void
    var onCancel: () -> Void

    // MARK: - Screen State

    enum ScreenState {
        case searching
        case manual
    }
    @State private var screenState: ScreenState = .searching

    // MARK: - Search State

    @State private var searchQuery = ""
    @State private var searchResults: [FoodSearchResult] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var hasSearched = false
    @State private var searchTask: Task<Void, Never>?

    // MARK: - Manual Form State

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
                searchView
            case .manual:
                manualFormView
            }
        }
        .background(FoodiaryDesign.pulseBackground)
        .navigationTitle(L10n["nav.add_food"])
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    if screenState == .manual {
                        screenState = .searching
                    } else {
                        onCancel()
                    }
                }) {
                    Image(systemName: screenState == .manual ? "arrow.left" : "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(PulseIconButtonStyle(fgColor: FoodiaryDesign.pulseMuted, size: 36))
            }
        }
    }

    // MARK: - Search View

    private var searchView: some View {
        VStack(spacing: 16) {
            searchBar

            // Content area — fills remaining space so the search bar
            // always stays pinned at the top regardless of state.
            Group {
                if isSearching {
                    loadingView
                } else if let error = searchError {
                    searchFeedback(text: error, icon: "exclamationmark.circle", isError: true)
                } else if hasSearched && searchResults.isEmpty {
                    noResultsView
                } else if !searchResults.isEmpty {
                    searchResultsList
                } else {
                    emptySearchPrompt
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onChange(of: searchQuery) { _, newValue in
            performSearch(query: newValue)
        }
    }

    // MARK: Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(FoodiaryDesign.mutedFg)
                .font(.system(size: 15))

            TextField(L10n["add_food.search_placeholder"], text: $searchQuery)
                .font(FoodiaryTypography.body)
                .autocorrectionDisabled()

            if isSearching {
                ProgressView()
                    .scaleEffect(0.8)
            }

            if !searchQuery.isEmpty {
                Button(action: clearSearch) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(FoodiaryDesign.mutedFg)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(FoodiaryDesign.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
                )
        )
    }

    // MARK: Results List

    private var searchResultsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(searchResults) { result in
                    Button(action: { addFromSearch(result) }) {
                        FoodSearchResultRow(result: result)
                    }
                    .buttonStyle(.plain)

                    if result.id != searchResults.last?.id {
                        Divider()
                            .padding(.leading, 12)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(FoodiaryDesign.pulseSurfaceSoft)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
                    )
            )
        }
    }

    // MARK: No Results

    private var noResultsView: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 32)

            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(FoodiaryDesign.mutedFg)

            Text(L10n["add_food.no_results"])
                .font(FoodiaryTypography.body)
                .foregroundColor(FoodiaryDesign.mutedFg)
                .multilineTextAlignment(.center)

            Button(action: { screenState = .manual }) {
                Text(L10n["add_food.manual_button"])
            }
            .buttonStyle(PulsePrimaryButtonStyle())

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Loading

    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 60)
            ProgressView()
                .scaleEffect(1.2)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Empty Prompt

    private var emptySearchPrompt: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 80)

            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(FoodiaryDesign.mutedFg)

            Text(L10n["add_food.search_placeholder"])
                .font(FoodiaryTypography.body)
                .foregroundColor(FoodiaryDesign.mutedFg)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Feedback

    private func searchFeedback(text: String, icon: String, isError: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13))
            Text(text)
                .font(FoodiaryTypography.bodySm)
        }
        .foregroundColor(isError ? FoodiaryDesign.pulseDanger : FoodiaryDesign.pulseMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(FoodiaryDesign.pulseSurfaceSoft)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
                )
        )
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

    private func addFromSearch(_ result: FoodSearchResult) {
        onSave(result.toFoodItem())
    }

    private func clearSearch() {
        searchQuery = ""
        searchResults = []
        searchError = nil
        hasSearched = false
        isSearching = false
        searchTask?.cancel()
    }

    // MARK: - Manual Form View

    private var manualFormView: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.food_name"]).pulseSectionLabel()
                    TextField(L10n["add_food.name_placeholder"], text: $name)
                        .ringField()
                        .font(FoodiaryTypography.body)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(nameError ? Color.red : FoodiaryDesign.border, lineWidth: 1.5)
                        )
                    if nameError {
                        Text(L10n["add_food.name_error"])
                            .font(.system(size: 12)).foregroundColor(.red)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.calories"]).pulseSectionLabel()
                    TextField("0", text: $caloriesText)
                        .keyboardType(.numberPad)
                        .ringField()
                        .font(FoodiaryTypography.body)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(caloriesError ? Color.red : FoodiaryDesign.border, lineWidth: 1.5)
                        )
                    Text(L10n["add_food.calories_hint"])
                        .font(.system(size: 12))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                    if caloriesError {
                        Text(L10n["add_food.calories_error"])
                            .font(.system(size: 12)).foregroundColor(.red)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.macronutrients"]).pulseSectionLabel()
                    HStack(spacing: 8) {
                        macroField(label: "Protein", unit: "g", text: $proteinText)
                        macroField(label: "Carbs", unit: "g", text: $carbsText)
                        macroField(label: "Fat", unit: "g", text: $fatText)
                    }
                    Text("Optional — enter grams for each macronutrient.")
                        .font(.system(size: 12))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.note_optional"]).pulseSectionLabel()
                    TextField(L10n["add_food.note_placeholder"], text: $note)
                        .ringField()
                        .font(FoodiaryTypography.body)
                }

                Spacer(minLength: 12)

                Button(action: saveManualItem) {
                    Text(L10n["action.save_food_item"])
                }
                .buttonStyle(PulsePrimaryButtonStyle())
            }
        }
        .padding(20)
    }

    func macroField(label: String, unit: String, text: Binding<String>) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(FoodiaryDesign.mutedFg)
            TextField("0", text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .ringField()
                .font(.system(size: 14, weight: .semibold))
        }
    }

    // MARK: - Save Manual

    private func saveManualItem() {
        nameError = name.trimmingCharacters(in: .whitespaces).isEmpty
        caloriesError = false

        guard !nameError else { return }

        guard let calories = Int(caloriesText.trimmingCharacters(in: .whitespaces)), calories >= 0 else {
            caloriesError = true
            return
        }

        let protein = Int(proteinText.trimmingCharacters(in: .whitespaces)) ?? 0
        let carbs = Int(carbsText.trimmingCharacters(in: .whitespaces)) ?? 0
        let fat = Int(fatText.trimmingCharacters(in: .whitespaces)) ?? 0

        let item = FoodItem(
            name: name.trimmingCharacters(in: .whitespaces),
            calories: calories,
            protein: max(0, protein),
            carbs: max(0, carbs),
            fat: max(0, fat),
            note: note.trimmingCharacters(in: .whitespaces)
        )
        onSave(item)
    }
}

// MARK: - Search Result Row

struct FoodSearchResultRow: View {
    let result: FoodSearchResult

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(result.name)
                    .font(FoodiaryTypography.bodyBold)
                    .foregroundColor(FoodiaryDesign.black)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if let brand = result.brand, !brand.isEmpty {
                        Text(brand)
                            .font(.system(size: 12))
                            .foregroundColor(FoodiaryDesign.mutedFg)
                            .lineLimit(1)
                    }
                    if let serving = result.servingDescription, !serving.isEmpty {
                        Text("·")
                            .foregroundColor(FoodiaryDesign.mutedFg)
                        Text(serving)
                            .font(.system(size: 12))
                            .foregroundColor(FoodiaryDesign.mutedFg)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(result.calories) kcal")
                    .font(FoodiaryTypography.bodyBold)
                    .foregroundColor(FoodiaryDesign.pulsePrimary)

                Text(result.sourceDisplayName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(sourceBadgeColor)
                    )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .contentShape(Rectangle())
    }

    private var sourceBadgeColor: Color {
        switch result.source {
        case .fatsecret: return Color(hex: "059669")
        case .custom: return FoodiaryDesign.accent
        case .usda: return Color(hex: "D97706")
        case .openFoodFacts: return Color(hex: "7C3AED")
        }
    }
}
