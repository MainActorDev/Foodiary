import SwiftUI

// MARK: - Day Detail Card

struct DayDetailCard: View {
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
                    Text("\(dayName) plan").font(.system(size: 13, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk)
                    Spacer()
                    Text("\(plan.totalCalories) / \(targetCalories)").font(.system(size: 12, weight: .medium)).foregroundColor(FoodiaryDesign.pulseMuted)
                }
                HStack(spacing: 6) {
                    ForEach(plan.meals, id: \.type.rawValue) { meal in
                        Capsule().fill(FoodiaryDesign.pulseMealAccent(for: meal.type)).frame(height: 8)
                    }
                }
                Text(isPast ? "This day is read-only." : "This day is planned and still has room for adjustment.")
                    .font(.system(size: 13)).foregroundColor(FoodiaryDesign.pulseMuted)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(FoodiaryDesign.pulseSurface).shadow(color: Color(hex: "141428").opacity(0.055), radius: 30, x: 0, y: 14))
            .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(Color(hex: "15142A").opacity(0.10), lineWidth: 1))

            // Meal slots
            VStack(spacing: 12) {
                HStack {
                    Text("MEAL SLOTS").font(.system(size: 13, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk)
                    Spacer()
                }
                ForEach(Array(plan.meals.enumerated()), id: \.element.id) { index, meal in
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
                    Text("\(dayName) plan").font(.system(size: 13, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk)
                    Spacer()
                    Text("0 / \(targetCalories)").font(.system(size: 12, weight: .medium)).foregroundColor(FoodiaryDesign.pulseMuted)
                }
                if isPast {
                    Text("No food was logged on this day.").font(.system(size: 13)).foregroundColor(FoodiaryDesign.pulseMuted)
                } else {
                    Text("This day is open — tap a meal slot to start planning.").font(.system(size: 13)).foregroundColor(FoodiaryDesign.pulseMuted)
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(FoodiaryDesign.pulseSurface).shadow(color: Color(hex: "141428").opacity(0.055), radius: 30, x: 0, y: 14))
            .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(Color(hex: "15142A").opacity(0.10), lineWidth: 1))

            if !isPast {
                VStack(spacing: 12) {
                    HStack {
                        Text("MEAL SLOTS").font(.system(size: 13, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk)
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
    var meal: Meal?
    var mealType: Meal.MealType?
    var isReadOnly: Bool = false
    var onTap: () -> Void

    private var type: Meal.MealType { meal?.type ?? mealType ?? .breakfast }
    private var calories: Int { meal?.totalCalories ?? 0 }
    private var subtitle: String {
        guard let meal else { return "Tap to add food" }
        let count = meal.itemCount
        if count == 0 { return "Tap to add food" }
        return "\(count) \(count == 1 ? "item" : "items") · planned"
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
