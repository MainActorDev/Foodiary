import SwiftUI

struct MealPlanView: View {
    @ObservedObject var state: AppState
    var onCreateMealPlan: () -> Void
    var onTapMeal: (Int) -> Void
    
    var body: some View {
        ScrollView {
            if state.hasTodayMealPlan, let plan = state.todayMealPlan {
                VStack(spacing: 12) {
                    HStack {
                        Text(L10n["meal_plan.header"])
                            .sectionLabel()
                        Spacer()
                        Text("\(state.plannedCalories) \(L10n["unit.kcal"])")
                            .font(FoodiaryTypography.bodySm)
                            .foregroundColor(FoodiaryDesign.mutedFg)
                    }
                    
                    ForEach(Array(plan.meals.enumerated()), id: \.element.id) { index, meal in
                        Button(action: { onTapMeal(index) }) {
                            MealCardView(meal: meal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(20)
            } else {
                VStack(spacing: 16) {
                    Spacer().frame(height: 80)
                    Text("🍽")
                        .font(.system(size: 48))
                        .opacity(0.6)
                    Text(L10n["today.empty.title"])
                        .font(FoodiaryTypography.title)
                        .foregroundColor(FoodiaryDesign.black)
                    Text(L10n["meal_plan.empty.subtitle"])
                        .font(FoodiaryTypography.body)
                        .foregroundColor(FoodiaryDesign.mutedFg)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Button(action: onCreateMealPlan) {
                        Text(L10n["action.create_meal_plan"])
                    }
                    .buttonStyle(NBButtonStyle())
                    .frame(width: 220)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
            }
        }
        .background(FoodiaryDesign.background)
    }
}
