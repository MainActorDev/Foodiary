import SwiftUI

struct PlanView: View {
    @Bindable var state: AppState
    @State private var weekOffset: Int = 0
    @State private var showMealDetail = false
    @State private var selectedMealIndex = 0

    private var weekStart: Date { weekStartFor(offset: weekOffset) }

    private func weekStartFor(offset: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = weekday == 1 ? -6 : 2 - weekday
        guard let thisMonday = calendar.date(byAdding: .day, value: mondayOffset, to: today),
              let result = calendar.date(byAdding: .day, value: offset * 7, to: thisMonday) else {
            return today
        }
        return result
    }

    private var weekDays: [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private var weekLabel: String {
        guard let end = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        let startStr = fmt.string(from: weekStart)
        let endDays = Calendar.current.component(.month, from: weekStart) == Calendar.current.component(.month, from: end)
        let efmt = DateFormatter()
        efmt.dateFormat = endDays ? "d" : "MMM d"
        return "\(startStr) – \(efmt.string(from: end))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                PulseTopbar(overline: "WEEK READINESS", title: L10n["nav.plan"], icon: .plus)
                weekCard
                weekSummary
                dayDetailSection
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

    // MARK: - Week Card (prototype: .week-card)

    private var weekCard: some View {
        VStack(spacing: 14) {
            // Header row
            HStack(spacing: 8) {
                Button(action: { weekOffset -= 1; state.selectedPlanDate = weekStart }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(FoodiaryDesign.pulseSurfaceSoft)
                        )
                }

                Text(weekLabel)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                    .frame(maxWidth: .infinity)

                Button(action: { weekOffset += 1; state.selectedPlanDate = weekStart }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(FoodiaryDesign.pulseSurfaceSoft)
                        )
                }
            }

            // Day pills grid
            HStack(spacing: 7) {
                ForEach(weekDays, id: \.self) { day in
                    dayPill(day: day)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(FoodiaryDesign.pulseSurface)
                .shadow(color: Color(hex: "141428").opacity(0.055), radius: 30, x: 0, y: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color(hex: "15142A").opacity(0.10), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func dayPill(day: Date) -> some View {
        let isSelected = Calendar.current.isDate(day, inSameDayAs: state.selectedPlanDate)
        let isToday = Calendar.current.isDateInToday(day)
        let isPast = day < Calendar.current.startOfDay(for: Date())
        let (hasData, totalCal) = state.hasMealData(for: day)
        let isOver = totalCal > state.targetCalories && hasData

        // Determine state: active, future, empty, or default
        let dayState: DayState = {
            if isSelected { return .active }
            if isOver { return .over }
            if !hasData && isPast { return .empty }
            if !hasData && !isToday { return .future }
            if isToday && !isSelected { return .today }
            return .default
        }()

        Button(action: { state.selectedPlanDate = day }) {
            VStack(spacing: 3) {
                Text(dayOfWeekShort(day))
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.7)
                    .textCase(.uppercase)
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(.system(size: 16, weight: .bold))
                Circle()
                    .fill(dayState == .over ? FoodiaryDesign.pulseDanger.opacity(0.6) : .clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 3)
            .background(
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(dayStateBg(dayState))
            )
            .foregroundColor(dayStateFg(dayState))
        }
        .buttonStyle(.plain)
    }

    enum DayState { case active, today, future, empty, over, `default` }

    private func dayStateBg(_ state: DayState) -> Color {
        switch state {
        case .active: return FoodiaryDesign.pulsePrimaryDark
        case .future: return FoodiaryDesign.pulseDayFuture
        case .empty: return FoodiaryDesign.pulseDayEmpty
        case .over: return Color(hex: "FEF2F2")
        case .today: return FoodiaryDesign.pulseSurfaceSoft
        case .default: return FoodiaryDesign.pulseSurfaceSoft
        }
    }

    private func dayStateFg(_ state: DayState) -> Color {
        switch state {
        case .active: return .white
        case .future: return FoodiaryDesign.pulseDayFutureFg
        case .empty: return FoodiaryDesign.pulseDayEmptyFg
        case .over: return FoodiaryDesign.pulseDanger
        case .today: return FoodiaryDesign.pulseInk
        case .default: return FoodiaryDesign.pulseMuted
        }
    }

    private func dayOfWeekShort(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "E"; return f.string(from: date)
    }

    // MARK: - Week Summary (prototype: .day-summary)

    private var weekSummary: some View {
        let planned = weekDays.filter { state.hasMealData(for: $0).hasPlan }.count

        return HStack(spacing: 10) {
            metricBox(value: "\(planned)/7", label: "Days planned")
            metricBox(value: "\(7 - planned)", label: "Open days")
        }
    }

    private func metricBox(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(FoodiaryDesign.pulseInk)
            Text(label)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .textCase(.uppercase)
                .tracking(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(FoodiaryDesign.pulseSurfaceSoft)
        )
    }

    // MARK: - Day Detail

    private var dayDetailSection: some View {
        Group {
            if let plan = state.planDateMealPlan {
                populatedDay(plan: plan)
            } else {
                emptyDay
            }
        }
    }

    private func populatedDay(plan: MealPlan) -> some View {
        let dayName = fullDayName(state.selectedPlanDate)

        return VStack(spacing: 14) {
            // Day card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(dayName) plan")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(FoodiaryDesign.pulseInk)
                    Spacer()
                    Text("\(plan.totalCalories) / \(state.targetCalories)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }
                // Segments inside card
                HStack(spacing: 6) {
                    ForEach(plan.meals, id: \.type.rawValue) { meal in
                        Capsule()
                            .fill(FoodiaryDesign.pulseMealAccent(for: meal.type))
                            .frame(height: 8)
                    }
                }
                Text(state.isPlanDatePast
                     ? "This day is read-only."
                     : "This day is planned and still has room for adjustment.")
                    .font(.system(size: 13))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(FoodiaryDesign.pulseSurface)
                    .shadow(color: Color(hex: "141428").opacity(0.055), radius: 30, x: 0, y: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color(hex: "15142A").opacity(0.10), lineWidth: 1)
            )

            // Meal slots
            VStack(spacing: 12) {
                HStack {
                    Text("MEAL SLOTS")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(FoodiaryDesign.pulseInk)
                    Spacer()
                    Text("Edit")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }

                ForEach(Array(plan.meals.enumerated()), id: \.element.id) { index, meal in
                    Button(action: {
                        if !state.isPlanDatePast {
                            selectedMealIndex = index
                            showMealDetail = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text(meal.type == .breakfast ? "🍳" :
                                 meal.type == .lunch ? "🍱" :
                                 meal.type == .snack ? "🍌" : "🍽️")
                                .font(.system(size: 22))
                                .frame(width: 50, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(FoodiaryDesign.pulseMealTint(for: meal.type))
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(meal.type.localizedDisplayName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(FoodiaryDesign.pulseInk)
                                Text(mealSubtitle(meal))
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
                    .disabled(state.isPlanDatePast)
                }
            }
        }
    }

    private func mealSubtitle(_ meal: Meal) -> String {
        let count = meal.itemCount
        if count == 0 { return "Tap to add food" }
        return "\(count) \(count == 1 ? "item" : "items") · planned"
    }

    // MARK: - Empty Day

    private var emptyDay: some View {
        let isPast = state.isPlanDatePast
        let dayName = fullDayName(state.selectedPlanDate)

        return VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(dayName) plan")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(FoodiaryDesign.pulseInk)
                    Spacer()
                    Text("0 / \(state.targetCalories)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }

                if isPast {
                    Text("No food was logged on this day.")
                        .font(.system(size: 13))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                } else {
                    Text("This day is open — tap a meal slot to start planning.")
                        .font(.system(size: 13))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(FoodiaryDesign.pulseSurface)
                    .shadow(color: Color(hex: "141428").opacity(0.055), radius: 30, x: 0, y: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color(hex: "15142A").opacity(0.10), lineWidth: 1)
            )

            if !isPast {
                VStack(spacing: 12) {
                    HStack {
                        Text("MEAL SLOTS")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(FoodiaryDesign.pulseInk)
                        Spacer()
                    }

                    ForEach(Meal.MealType.allCases, id: \.rawValue) { type in
                        Button(action: { createPlanAndAddFood(type: type) }) {
                            HStack(spacing: 12) {
                                Text(type == .breakfast ? "🍳" : type == .lunch ? "🍱" :
                                     type == .snack ? "🍌" : "🍽️")
                                    .font(.system(size: 22))
                                    .frame(width: 50, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(FoodiaryDesign.pulseMealTint(for: type))
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(type.localizedDisplayName)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(FoodiaryDesign.pulseInk)
                                    Text("Tap to add food")
                                        .font(.system(size: 12))
                                        .foregroundColor(FoodiaryDesign.pulseMuted)
                                }

                                Spacer()

                                Text("0 kcal")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(FoodiaryDesign.pulseInk)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func createPlanAndAddFood(type: Meal.MealType) {
        if state.planDateMealPlan == nil {
            state.createMealPlan(for: state.selectedPlanDate)
        }
        guard let plan = state.planDateMealPlan,
              let index = plan.meals.firstIndex(where: { $0.type == type }) else { return }
        selectedMealIndex = index
        showMealDetail = true
    }

    private func fullDayName(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "EEEE"; return f.string(from: date)
    }
}
