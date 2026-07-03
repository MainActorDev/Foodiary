import SwiftUI

struct TodayDashboardView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    @Bindable var state: AppState
    var onCreateMealPlan: () -> Void
    var onTapMeal: (Int) -> Void

    var body: some View {
        ScrollView {
            if let plan = state.todayMealPlan {
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
            }
        }
        .background(FoodiaryDesign.pulseBackground)
        .onAppear { if !state.hasTodayMealPlan { onCreateMealPlan() } }
    }

    // MARK: - Date

    private func todayDateString() -> String {
        DateFormatter.indonesianDate.string(from: Date()).uppercased()
    }
}
