import SwiftUI

// MARK: - Day Detail Card

struct DayDetailCard: View {
    @EnvironmentObject private var localeManager: LocaleManager
    let plan: MealPlan?
    let targetCalories: Double
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
                MealDistributionBar(meals: plan.sortedMeals, totalCalories: plan.totalCalories, targetCalories: targetCalories)
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
                        .font(.system(size: 13))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
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

// MARK: - Meal Distribution Bar

/// Proportional stacked bar showing each meal's calorie share of the day's total.
/// Replaces the former decorative equal-width capsules.
struct MealDistributionBar: View {
    let meals: [Meal]
    let totalCalories: Int
    let targetCalories: Double

    private var isOverTarget: Bool {
        Double(totalCalories) > targetCalories && totalCalories > 0
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(isOverTarget ? FoodiaryDesign.pulseDanger.opacity(0.12) : FoodiaryDesign.pulseSurfaceSoft)

                if totalCalories > 0 {
                    mealSegments(width: width)
                }
            }
        }
        .frame(height: 10)
    }

    @ViewBuilder
    private func mealSegments(width: CGFloat) -> some View {
        let maxScale = max(Double(totalCalories), targetCalories)
        let filledWidth = width * (CGFloat(totalCalories) / CGFloat(maxScale))

        // Precompute segment widths and offsets
        var xOffset: CGFloat = 0
        let segments: [(meal: Meal, width: CGFloat, offset: CGFloat)] = meals.compactMap { meal in
            let segmentWidth = filledWidth * (CGFloat(meal.totalCalories) / CGFloat(totalCalories))
            let result = (meal, segmentWidth, xOffset)
            xOffset += segmentWidth
            return segmentWidth > 0 ? result : nil
        }

        ZStack(alignment: .leading) {
            ForEach(segments, id: \.meal.type.rawValue) { seg in
                Rectangle()
                    .fill(FoodiaryDesign.pulseMealAccent(for: seg.meal.type))
                    .frame(width: seg.width, height: 10)
                    .offset(x: seg.offset)
            }
        }
        .frame(width: filledWidth, height: 10, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}
