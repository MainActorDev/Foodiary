import SwiftUI

struct MealDetailView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    @Bindable var state: AppState
    let mealIndex: Int
    var date: Date = Date()
    @Binding var isPresented: Bool
    @State private var showAddFood = false

    var mealPlan: MealPlan? {
        if Calendar.current.isDateInToday(date) {
            return state.todayMealPlan
        }
        return state.planDateMealPlan
    }

    var meal: Meal? {
        guard let plan = mealPlan, mealIndex < plan.sortedMeals.count else { return nil }
        return plan.sortedMeals[mealIndex]
    }

    var isReadOnly: Bool {
        state.isDateInPreviousWeek(date)
    }

    var body: some View {
        Group {
            if let meal = meal {
                ScrollView {
                    VStack(spacing: 20) {
                        MealHeroHeader(
                            mealType: meal.type,
                            totalCalories: meal.totalCalories,
                            totalProtein: meal.items.reduce(0) { $0 + $1.protein },
                            totalCarbs: meal.items.reduce(0) { $0 + $1.carbs },
                            totalFat: meal.items.reduce(0) { $0 + $1.fat }
                        )

                        if meal.items.isEmpty {
                            emptyState(mealType: meal.type)
                        } else {
                            foodListSection(meal: meal)
                        }

                        if !isReadOnly {
                            Button(action: { showAddFood = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                    Text(L10n["action.add_food"])
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(FoodiaryDesign.pulseInkFixed))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
                .background(FoodiaryDesign.pulseBackground)
                .navigationTitle(meal.type.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .pulseBackButton()
                .toolbar {
                    if !isReadOnly {
                        ToolbarItem(placement: .topBarTrailing) {
                            PulseToolbarButton(icon: "plus") { showAddFood = true }
                        }
                    }
                }
                .sheet(isPresented: $showAddFood) {
                    NavigationStack {
                        AddFoodItemView(
                            onSave: { item in
                                if Calendar.current.isDateInToday(date) {
                                    state.addFoodItem(item, toMealAt: mealIndex)
                                } else {
                                    state.addFoodItem(item, toMealAt: mealIndex, for: date)
                                }
                                showAddFood = false
                            },
                            onCancel: { showAddFood = false }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Food List Section

    private func foodListSection(meal: Meal) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n["label.food_items"])
                    .pulseSectionLabel()
                Spacer()
                Text(L10n["meal_detail.item_count", meal.items.count])
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
            }

            VStack(spacing: 10) {
                ForEach(Array(meal.items.enumerated()), id: \.element.id) { itemIndex, item in
                    FoodItemMacroRow(
                        item: item,
                        isReadOnly: isReadOnly,
                        onDelete: {
                            if Calendar.current.isDateInToday(date) {
                                state.deleteFoodItem(mealIndex: mealIndex, itemIndex: itemIndex)
                            } else {
                                state.deleteFoodItem(mealIndex: mealIndex, itemIndex: itemIndex, for: date)
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Empty State

    private func emptyState(mealType: Meal.MealType) -> some View {
        VStack(spacing: 12) {
            Text(mealType.emoji)
                .font(.system(size: 40))
                .frame(width: 72, height: 72)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(FoodiaryDesign.pulseSurfaceSoft))

            Text(L10n["meal_detail.empty.title"])
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(FoodiaryDesign.pulseInk)

            Text(L10n["meal_detail.empty.subtitle"])
                .font(.system(size: 13))
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

// MARK: - Meal Hero Header

/// Gradient hero card showing the meal's total calories and macro pills.
/// Color matches the meal type (amber/mint/pink/blue).
struct MealHeroHeader: View {
    let mealType: Meal.MealType
    let totalCalories: Int
    let totalProtein: Int
    let totalCarbs: Int
    let totalFat: Int

    private var hasData: Bool { totalCalories > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text(mealType.emoji)
                    .font(.system(size: 44))

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(totalCalories)")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(-1.5)
                    Text(L10n["unit.kcal"])
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .textCase(.uppercase)
                        .tracking(0.8)
                }
            }

            Text(mealType.displayName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 8) {
                macroPill(label: L10n["label.protein_short"], value: totalProtein)
                macroPill(label: L10n["label.carbs_short"], value: totalCarbs)
                macroPill(label: L10n["label.fat_short"], value: totalFat)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(FoodiaryDesign.pulseMealHeroGradient(for: mealType))
        )
    }

    private func macroPill(label: String, value: Int) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(.white.opacity(0.8))
                .frame(width: 6, height: 6)
            if hasData {
                Text("\(value)g \(label)")
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
            } else {
                Text(label)
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(Capsule().fill(.white.opacity(0.18)))
    }
}

// MARK: - Food Item Macro Row

/// Food item row with inline macro breakdown (P/C/F).
/// Replaces the old FoodItemRowView which only showed calories.
struct FoodItemMacroRow: View {
    let item: FoodItem
    var isReadOnly: Bool = false
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                    .lineLimit(2)

                if !item.note.isEmpty {
                    Text(item.note)
                        .font(.system(size: 11))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }

                HStack(spacing: 10) {
                    macroLabel(value: item.protein, unit: "P")
                    macroLabel(value: item.carbs, unit: "C")
                    macroLabel(value: item.fat, unit: "F")
                }
                .padding(.top, 2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(item.calories)")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(FoodiaryDesign.pulsePrimary)
                Text(L10n["unit.kcal"])
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
                    .textCase(.uppercase)
            }

            if !isReadOnly {
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(FoodiaryDesign.pulseDanger)
                        .frame(width: 28, height: 28)
                        .background(RoundedRectangle(cornerRadius: 10).fill(FoodiaryDesign.pulseDanger.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(FoodiaryDesign.pulseSurface))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1))
    }

    private func macroLabel(value: Int, unit: String) -> some View {
        HStack(spacing: 2) {
            Text("\(value)g")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(FoodiaryDesign.pulseInk)
            Text(unit)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(FoodiaryDesign.pulseMuted)
        }
    }
}
