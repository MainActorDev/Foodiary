import SwiftUI

// MARK: - Action Strip
///
/// Dark strip at the bottom of the Today screen with a suggestion
/// and a floating "+" button that opens a meal-type picker.

struct TodayActionStrip: View {
    @EnvironmentObject private var localeManager: LocaleManager
    let plan: MealPlan
    var onTapMeal: (Int) -> Void

    @State private var showPicker = false

    private var hasEmpty: Bool {
        plan.sortedMeals.contains { $0.items.isEmpty }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(L10n["today.action.next_best"]).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text(hasEmpty
                     ? L10n["today.action.add_or_refine"]
                     : L10n["today.action.all_planned"])
                    .font(.system(size: 12)).foregroundColor(.white.opacity(0.64))
            }
            Spacer()
            Button {
                showPicker = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(FoodiaryDesign.pulseInkFixed)
                    .frame(width: 42, height: 42)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(.white))
            }
        }
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(FoodiaryDesign.pulseInkFixed))
        .sheet(isPresented: $showPicker) {
            MealTypePickerSheet(
                meals: plan.sortedMeals,
                onSelect: { index in
                    showPicker = false
                    onTapMeal(index)
                }
            )
            .presentationDetents([.height(440)])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Meal Type Picker Sheet

struct MealTypePickerSheet: View {
    @EnvironmentObject private var localeManager: LocaleManager
    let meals: [Meal]
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(L10n["today.action.choose_meal"])
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(FoodiaryDesign.pulseInk)
                .padding(.top, 20)
                .padding(.bottom, 16)

            VStack(spacing: 10) {
                ForEach(Array(meals.enumerated()), id: \.element.id) { index, meal in
                    Button {
                        onSelect(index)
                    } label: {
                        HStack(spacing: 14) {
                            Text(meal.type.emoji)
                                .font(.system(size: 24))
                                .frame(width: 48, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(FoodiaryDesign.pulseMealTint(for: meal.type))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(FoodiaryDesign.pulseMealAccent(for: meal.type).opacity(0.24), lineWidth: 1)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(meal.type.displayName)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(FoodiaryDesign.pulseInk)
                                Text(meal.itemCount == 0
                                     ? L10n["today.meal.tap_to_add"]
                                     : L10n["today.meal.items_planned", meal.itemCount])
                                    .font(.system(size: 12))
                                    .foregroundColor(FoodiaryDesign.pulseMuted)
                            }

                            Spacer()

                            Text("\(meal.totalCalories) kcal")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(FoodiaryDesign.pulseInk)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(FoodiaryDesign.pulseMuted)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(FoodiaryDesign.pulseSurface)
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
            .padding(.bottom, 24)
        }
        .background(FoodiaryDesign.pulseBackground)
    }
}
