import SwiftUI

// MARK: - Search Food View
///
/// Search-first flow: text field → debounced search → results list.
/// Tapping a result immediately returns the FoodItem.

struct SearchFoodView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    @Binding var searchQuery: String
    var searchResults: [FoodSearchResult]
    var isSearching: Bool
    var hasSearched: Bool
    var searchError: String?
    var onSelectResult: (FoodSearchResult) -> Void
    var onManualAdd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            searchBar

            Group {
                if isSearching {
                    loadingView
                } else if let error = searchError {
                    feedbackView(text: error, icon: "exclamationmark.circle", isError: true)
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
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(FoodiaryDesign.mutedFg).font(.system(size: 15))
            TextField(L10n["add_food.search_placeholder"], text: $searchQuery)
                .font(FoodiaryTypography.body).autocorrectionDisabled()
            if isSearching {
                ProgressView().scaleEffect(0.8)
            }
            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(FoodiaryDesign.mutedFg)
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(FoodiaryDesign.white)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)))
    }

    // MARK: - Results

    private var resultsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(searchResults) { result in
                    Button(action: { onSelectResult(result) }) {
                        FoodSearchResultRow(result: result)
                    }
                    .buttonStyle(.plain)
                    if result.id != searchResults.last?.id {
                        Divider().padding(.leading, 12)
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 12).fill(FoodiaryDesign.pulseSurfaceSoft)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)))
        }
    }

    // MARK: - States

    private var noResultsView: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 32)
            Image(systemName: "magnifyingglass").font(.system(size: 40)).foregroundColor(FoodiaryDesign.mutedFg)
            Text(L10n["add_food.no_results"]).font(FoodiaryTypography.body).foregroundColor(FoodiaryDesign.mutedFg).multilineTextAlignment(.center)
            Button(action: onManualAdd) { Text(L10n["add_food.manual_button"]) }.buttonStyle(PulsePrimaryButtonStyle())
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 60)
            ProgressView().scaleEffect(1.2)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyPrompt: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 80)
            Image(systemName: "magnifyingglass").font(.system(size: 40)).foregroundColor(FoodiaryDesign.mutedFg)
            Text(L10n["add_food.search_placeholder"]).font(FoodiaryTypography.body).foregroundColor(FoodiaryDesign.mutedFg)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func feedbackView(text: String, icon: String, isError: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 13))
            Text(text).font(FoodiaryTypography.bodySm)
        }
        .foregroundColor(isError ? FoodiaryDesign.pulseDanger : FoodiaryDesign.pulseMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(FoodiaryDesign.pulseSurfaceSoft)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)))
    }
}
