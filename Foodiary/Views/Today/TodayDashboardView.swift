import SwiftUI

struct TodayDashboardView: View {
    @Bindable var state: AppState
    var onCreateMealPlan: () -> Void
    var onTapMeal: (Int) -> Void

    var body: some View {
        ScrollView {
            if state.hasTodayMealPlan, let plan = state.todayMealPlan {
                VStack(spacing: 12) {
                    PulseTopbar(overline: todayDateString(), title: L10n["nav.today"], icon: nil)
                    TodayHeroSection(
                        remainingCalories: state.remainingCalories,
                        calorieProgress: state.calorieProgress,
                        plannedCalories: state.plannedCalories,
                        targetCalories: state.targetCalories,
                        plan: plan,
                        todayDateString: todayDateString(),
                        onTapMeal: onTapMeal
                    )
                    TodayMacroGrid(
                        totalProtein: state.totalProtein,
                        totalCarbs: state.totalCarbs,
                        totalFat: state.totalFat
                    )
                    TodayActionStrip(plan: plan, onTapMeal: onTapMeal)
                    TodayMealTimeline(plan: plan, onTapMeal: onTapMeal)
                }
                .padding(18)
            } else {
                emptyState
            }
        }
        .background(FoodiaryDesign.pulseBackground)
    }

    // MARK: - Date

    private func todayDateString() -> String {
        DateFormatter.indonesianDate.string(from: Date()).uppercased()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 80)
            Text("📋").font(.system(size: 56)).opacity(0.3)
            Text(L10n["today.empty.title"]).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(FoodiaryDesign.pulseInk)
            Text(L10n["today.empty.subtitle"]).font(.system(size: 14)).foregroundColor(FoodiaryDesign.pulseMuted).multilineTextAlignment(.center).padding(.horizontal, 40)
            Button(action: onCreateMealPlan) { Text(L10n["action.create_meal_plan"]) }
                .buttonStyle(PulsePrimaryButtonStyle()).frame(width: 240)
        }
        .frame(maxWidth: .infinity).padding(20)
    }
}
