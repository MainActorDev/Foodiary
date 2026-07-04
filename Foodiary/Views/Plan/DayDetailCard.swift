import SwiftUI

// MARK: - Day Detail Card

struct DayDetailCard: View {
    @EnvironmentObject private var localeManager: LocaleManager
    let plan: MealPlan?
    let targetCalories: Int
    let isPast: Bool
    let dayName: String
    var onTapMeal: (Int) -> Void
    var onCreatePlanAndAddFood: (Meal.MealType) -> Void

    var body: some View {
        VStack(spacing: 14) {
            if let plan {
                populatedDay(plan: plan)
            } else {
                emptyDay
            }
        }
    }

    // MARK: - Populated Day

    private func populatedDay(plan: MealPlan) -> some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(L10n["plan.day_plan_format", dayName]).font(.system(size: 13, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk)
                    Spacer()
                    Text("\(plan.totalCalories) / \(targetCalories)").font(.system(size: 12, weight: .medium)).foregroundColor(FoodiaryDesign.pulseMuted)
                }
                HStack(spacing: 6) {
                    ForEach(plan.sortedMeals, id: \.type.rawValue) { meal in
                        Capsule().fill(FoodiaryDesign.pulseMealAccent(for: meal.type)).frame(height: 8)
                    }
                }
                Text(isPast ? L10n["plan.read_only"] : L10n["plan.planned_adjustable"])
                    .font(.system(size: 13)).foregroundColor(FoodiaryDesign.pulseMuted)
            }
            .padding(16)
            .pulseCard(cornerRadius: 26, padding: 0)

            // Meal slots
            VStack(spacing: 12) {
                HStack {
                    Text(L10n["MEAL SLOTS"]).font(.system(size: 13, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk)
                    Spacer()
                }
                ForEach(Array(plan.sortedMeals.enumerated()), id: \.element.id) { index, meal in
                    MealSlotRow(meal: meal, isReadOnly: isPast, onTap: { onTapMeal(index) })
                }
            }
        }
    }

    // MARK: - Empty Day

    private var emptyDay: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(L10n["plan.day_plan_format", dayName]).font(.system(size: 13, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk)
                    Spacer()
                    Text("0 / \(targetCalories)").font(.system(size: 12, weight: .medium)).foregroundColor(FoodiaryDesign.pulseMuted)
                }
                if isPast {
                    Text(L10n["No food was logged on this day."]).font(.system(size: 13)).foregroundColor(FoodiaryDesign.pulseMuted)
                } else {
                    Text(L10n["This day is open — tap a meal slot to start planning."])
                }
            }
            .padding(16)
            .pulseCard(cornerRadius: 26, padding: 0)

            if !isPast {
                VStack(spacing: 12) {
                    HStack {
                        Text(L10n["MEAL SLOTS"]).font(.system(size: 13, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk)
                        Spacer()
                    }
                    ForEach(Meal.MealType.allCases, id: \.rawValue) { type in
                        Button(action: { onCreatePlanAndAddFood(type) }) {
                            MealSlotRow(meal: nil, mealType: type, onTap: {})
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Meal Slot Row

struct MealSlotRow: View {
    @EnvironmentObject private var localeManager: LocaleManager
    var meal: Meal?
    var mealType: Meal.MealType?
    var isReadOnly: Bool = false
    var onTap: () -> Void

    private var type: Meal.MealType { meal?.type ?? mealType ?? .breakfast }
    private var calories: Int { meal?.totalCalories ?? 0 }
    private var subtitle: String {
        guard let meal else { return L10n["today.meal.tap_to_add"] }
        let count = meal.itemCount
        if count == 0 { return L10n["today.meal.tap_to_add"] }
        return L10n["today.meal.items_planned", count]
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(type.emoji).font(.system(size: 22))
                    .frame(width: 50, height: 50)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(FoodiaryDesign.pulseMealTint(for: type)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName).font(.system(size: 14, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk)
                    Text(subtitle).font(.system(size: 12)).foregroundColor(FoodiaryDesign.pulseMuted)
                }
                Spacer()
                Text("\(calories) kcal").font(.system(size: 14, weight: .black)).foregroundColor(FoodiaryDesign.pulseInk)
            }
        }
        .buttonStyle(.plain)
        .disabled(isReadOnly)
    }
}
