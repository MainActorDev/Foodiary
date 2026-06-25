import SwiftUI

struct PlanView: View {
    @Bindable var state: AppState
    @State private var weekOffset: Int = 0
    @State private var showMealDetail = false
    @State private var selectedMealIndex = 0

    private var weekStart: Date { weekStartFor(offset: weekOffset) }

    private var weekDays: [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private var weekLabel: String {
        guard let end = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) else { return "" }
        let startStr = DateFormatter.weekLabel.string(from: weekStart)
        let sameMonth = Calendar.current.component(.month, from: weekStart) == Calendar.current.component(.month, from: end)
        let endStr = sameMonth
            ? DateFormatter.weekLabelDayOnly.string(from: end)
            : DateFormatter.weekLabel.string(from: end)
        return "\(startStr) – \(endStr)"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                PulseTopbar(overline: "WEEK READINESS", title: L10n["nav.plan"], icon: .plus)
                WeekCard(
                    weekOffset: $weekOffset,
                    selectedPlanDate: $state.selectedPlanDate,
                    weekStart: weekStart,
                    weekLabel: weekLabel,
                    weekDays: weekDays,
                    hasMealData: { state.hasMealData(for: $0) },
                    targetCalories: state.targetCalories
                )
                WeekSummary(
                    plannedDays: weekDays.filter { state.hasMealData(for: $0).hasPlan }.count,
                    totalDays: 7
                )
                DayDetailCard(
                    plan: state.planDateMealPlan,
                    targetCalories: state.targetCalories,
                    isPast: state.isPlanDatePast,
                    dayName: DateFormatter.fullDayName.string(from: state.selectedPlanDate),
                    onTapMeal: { index in
                        selectedMealIndex = index
                        showMealDetail = true
                    },
                    onCreatePlanAndAddFood: { type in
                        if state.planDateMealPlan == nil {
                            state.createMealPlan(for: state.selectedPlanDate)
                        }
                        guard let plan = state.planDateMealPlan,
                              let index = plan.meals.firstIndex(where: { $0.type == type }) else { return }
                        selectedMealIndex = index
                        showMealDetail = true
                    }
                )
            }
            .padding(18)
        }
        .background(FoodiaryDesign.pulseBackground)
        .onAppear { state.loadMealPlansForWeek(containing: weekStart) }
        .onChange(of: weekOffset) { _, newOffset in
            state.selectedPlanDate = weekStartFor(offset: newOffset)
            state.loadMealPlansForWeek(containing: weekStart)
        }
        .navigationDestination(isPresented: $showMealDetail) {
            MealDetailView(state: state, mealIndex: selectedMealIndex, date: state.selectedPlanDate, isPresented: $showMealDetail)
        }
    }

    private func weekStartFor(offset: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = weekday == 1 ? -6 : 2 - weekday
        guard let thisMonday = calendar.date(byAdding: .day, value: mondayOffset, to: today),
              let result = calendar.date(byAdding: .day, value: offset * 7, to: thisMonday) else { return today }
        return result
    }
}
