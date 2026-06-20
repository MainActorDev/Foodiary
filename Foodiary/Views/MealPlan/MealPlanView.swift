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
                        Text("TODAY'S MEALS")
                            .sectionLabel()
                        Spacer()
                        Text("\(state.plannedCalories) kcal")
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
                    Text("No meal plan for today")
                        .font(FoodiaryTypography.title)
                        .foregroundColor(FoodiaryDesign.black)
                    Text("Create one to start adding food items.")
                        .font(FoodiaryTypography.body)
                        .foregroundColor(FoodiaryDesign.mutedFg)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Button(action: onCreateMealPlan) {
                        Text("CREATE MEAL PLAN")
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
