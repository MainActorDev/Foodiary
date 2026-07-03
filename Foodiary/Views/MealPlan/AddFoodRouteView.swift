import SwiftUI

// MARK: - Add Food Router

/// Centered "+" action router: pick a meal type → open AddFoodItemView → save to today's plan.
/// The centered button in MainTabView opens this view as a sheet.
struct AddFoodRouteView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    @Bindable var state: AppState
    @Binding var isPresented: Bool

    @State private var selectedMealType: Meal.MealType = .breakfast
    @State private var step: Step = .pickMeal

    enum Step {
        case pickMeal
        case addFood
    }

    var body: some View {
        NavigationStack {
            switch step {
            case .pickMeal:
                mealPicker
            case .addFood:
                AddFoodItemView(
                    onSave: { item in
                        saveItem(item)
                    },
                    onCancel: {
                        step = .pickMeal
                    }
                )
            }
        }
    }

    // MARK: - Meal Picker

    private var mealPicker: some View {
        VStack(spacing: 0) {
            // Handle bar
            HStack {
                Text(L10n["action.add_food"])
                    .font(FoodiaryTypography.pulseTitle)
                    .foregroundColor(FoodiaryDesign.pulseInk)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(FoodiaryDesign.pulseSurfaceSoft)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 22)
            .padding(.bottom, 16)

            VStack(spacing: 14) {
                ForEach(Meal.MealType.allCases, id: \.self) { mealType in
                    Button {
                        selectedMealType = mealType
                        step = .addFood
                    } label: {
                        HStack(spacing: 14) {
                            PulseMealIconTile(mealType: mealType)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(mealType.displayName)
                                    .font(FoodiaryTypography.pulseHeadline)
                                    .foregroundColor(FoodiaryDesign.pulseInk)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(FoodiaryDesign.pulseBorder)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(FoodiaryDesign.pulseSurface)
                                .shadow(color: FoodiaryDesign.pulsePrimaryDark.opacity(0.04), radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(FoodiaryDesign.pulseBackground)
    }

    // MARK: - Save

    private func saveItem(_ item: FoodItem) {
        if !state.hasTodayMealPlan {
            state.createTodayMealPlan()
        }
        let mealIndex = Meal.MealType.allCases.firstIndex(of: selectedMealType) ?? 0
        state.addFoodItem(item, toMealAt: mealIndex)
        isPresented = false
    }
}
