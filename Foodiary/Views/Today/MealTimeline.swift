import SwiftUI

// MARK: - Meal Timeline
///
/// Lists each meal slot with its emoji tile, name, subtitle, and calorie total.

struct TodayMealTimeline: View {
    let plan: MealPlan
    var onTapMeal: (Int) -> Void

    var body: some View {
        VStack(spacing: 11) {
            HStack {
                Text("MEAL TIMELINE")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                    .tracking(1.0)
                Spacer()
                Text("\(plan.meals.count) slots")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(FoodiaryDesign.pulsePrimary)
            }
            ForEach(Array(plan.meals.enumerated()), id: \.element.id) { index, meal in
                Button(action: { onTapMeal(index) }) {
                    HStack(spacing: 12) {
                        Text(meal.type.emoji)
                            .font(.system(size: 22)).frame(width: 50, height: 50)
                            .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(FoodiaryDesign.pulseMealTint(for: meal.type)))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(meal.type.displayName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(FoodiaryDesign.pulseInk)
                            Text(subtitle(for: meal))
                                .font(.system(size: 12))
                                .foregroundColor(FoodiaryDesign.pulseMuted)
                        }
                        Spacer()
                        Text("\(meal.totalCalories) kcal")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(FoodiaryDesign.pulseInk)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 6)
    }

    private func subtitle(for meal: Meal) -> String {
        let count = meal.itemCount
        if count == 0 { return "Tap to add food" }
        return "\(count) \(count == 1 ? "item" : "items") · planned"
    }
}
