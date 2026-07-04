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
        date < Calendar.current.startOfDay(for: Date())
    }

    var body: some View {
        Group {
            if let meal = meal {
                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Text(L10n["label.food_items"])
                                .pulseSectionLabel()
                            Spacer()
                            Text("\(meal.totalCalories) \(L10n["unit.kcal"])")
                                .font(FoodiaryTypography.pulseCaption)
                                .foregroundColor(FoodiaryDesign.pulseMuted)
                        }

                        VStack(spacing: 0) {
                            if meal.items.isEmpty {
                                VStack(spacing: 10) {
                                    Text(L10n["meal_detail.empty.title"])
                                        .font(FoodiaryTypography.pulseBody)
                                        .foregroundColor(FoodiaryDesign.pulseMuted)
                                    Text(L10n["meal_detail.empty.subtitle"])
                                        .font(FoodiaryTypography.pulseCaption)
                                        .foregroundColor(FoodiaryDesign.pulseMuted)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(28)
                            } else {
                                ForEach(Array(meal.items.enumerated()), id: \.element.id) { itemIndex, item in
                                    FoodItemRowView(
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

                                    if itemIndex < meal.items.count - 1 {
                                        Divider()
                                            .overlay(FoodiaryDesign.pulseDivider)
                                    }
                                }
                            }
                        }
                        .pulseCard(cornerRadius: 18)

                        if !isReadOnly {
                            Button(action: { showAddFood = true }) {
                                Text(L10n["action.add_food"])
                            }
                            .buttonStyle(PulsePrimaryButtonStyle())
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
}

struct FoodItemRowView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    let item: FoodItem
    var isReadOnly: Bool = false
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(FoodiaryTypography.pulseBodyBold)
                    .foregroundColor(FoodiaryDesign.pulseInk)
                if !item.note.isEmpty {
                    Text(item.note)
                        .font(FoodiaryTypography.pulseCaption)
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }
            }

            Spacer()

            Text("\(item.calories) \(L10n["unit.kcal"])")
                .font(FoodiaryTypography.pulseBodyBold)
                .foregroundColor(FoodiaryDesign.pulseInk)

            if !isReadOnly {
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                }
                .buttonStyle(NBIconButtonStyle(isDanger: true))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}
