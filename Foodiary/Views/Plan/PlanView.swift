import SwiftUI

struct PlanView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    @Bindable var state: AppState
    @State private var weekOffset: Int = 0
    @State private var showMealDetail = false
    @State private var selectedMealIndex = 0
    @State private var showMealTypePicker = false

    private var weekStart: Date { state.weekCalc.weekStart(offset: weekOffset) }

    private var weekDays: [Date] {
        state.weekCalc.daysInWeek(offset: weekOffset)
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
                PulseTopbar(overline: L10n["plan.week_readiness"], title: L10n["nav.plan"], icon: state.isPlanDatePast ? nil : .plus) {
                    if state.planDateMealPlan == nil {
                        state.createMealPlan(for: state.selectedPlanDate)
                    }
                    showMealTypePicker = true
                }
                WeekCard(
                    weekOffset: $weekOffset,
                    selectedPlanDate: $state.selectedPlanDate,
                    weekStart: weekStart,
                    weekLabel: weekLabel,
                    weekDays: weekDays,
                    hasMealData: { state.hasMealData(for: $0) },
                    targetCalories: state.targetCalories,
                    weekStartForOffset: { state.weekCalc.weekStart(offset: $0) }
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
                              let index = plan.sortedMeals.firstIndex(where: { $0.type == type }) else { return }
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
            state.selectedPlanDate = state.weekCalc.weekStart(offset: newOffset)
            state.loadMealPlansForWeek(containing: weekStart)
        }
        .navigationDestination(isPresented: $showMealDetail) {
            MealDetailView(state: state, mealIndex: selectedMealIndex, date: state.selectedPlanDate, isPresented: $showMealDetail)
        }
        .sheet(isPresented: $showMealTypePicker) {
            if let plan = state.planDateMealPlan {
                MealTypePickerSheet(
                    meals: plan.sortedMeals,
                    onSelect: { index in
                        showMealTypePicker = false
                        selectedMealIndex = index
                        showMealDetail = true
                    }
                )
                .presentationDetents([.height(440)])
                .presentationDragIndicator(.visible)
            }
        }
    }
}
