import SwiftUI

// MARK: - Plan View (Week Strip + Day Detail)

struct PlanView: View {
    @Bindable var state: AppState
    @State private var weekOffset: Int = 0
    @State private var showMealDetail = false
    @State private var selectedMealIndex = 0
    
    /// The start of the currently displayed week (Monday)
    private var weekStart: Date {
        weekStartFor(offset: weekOffset)
    }
    
    private func weekStartFor(offset: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = weekday == 1 ? -6 : 2 - weekday
        let thisMonday = calendar.date(byAdding: .day, value: mondayOffset, to: today)!
        return calendar.date(byAdding: .day, value: offset * 7, to: thisMonday)!
    }
    
    /// Array of 7 days starting from weekStart
    private var weekDays: [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
    
    private var weekLabel: String {
        let end = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        let startStr = fmt.string(from: weekStart)
        let endFormatter = DateFormatter()
        endFormatter.dateFormat = Calendar.current.component(.month, from: weekStart) == Calendar.current.component(.month, from: end)
            ? "d, yyyy" : "MMM d, yyyy"
        let endStr = endFormatter.string(from: end)
        return "\(startStr) – \(endStr)"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: Week Navigation
                weekStripSection
                
                // MARK: Selected Day Detail
                dayDetailSection
            }
            .padding(20)
        }
        .background(FoodiaryDesign.background)
        .onAppear {
            // Pre-load meal plans for the visible week
            state.loadMealPlansForWeek(containing: weekStart)
        }
        .onChange(of: weekOffset) { _, newOffset in
            // Auto-snap selected date to Monday of the new week
            state.selectedPlanDate = weekStartFor(offset: newOffset)
            state.loadMealPlansForWeek(containing: weekStart)
        }
        .navigationDestination(isPresented: $showMealDetail) {
            MealDetailView(
                state: state,
                mealIndex: selectedMealIndex,
                date: state.selectedPlanDate,
                isPresented: $showMealDetail
            )
        }
    }
    
    // MARK: - Week Strip
    
    var weekStripSection: some View {
        VStack(spacing: 12) {
            // Navigation row
            HStack(spacing: 8) {
                Button(action: {
                    weekOffset -= 1
                    // Snap selected date to Monday of new week
                    state.selectedPlanDate = weekStart
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(RingStepperButtonStyle())
                
                Text(weekLabel)
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(FoodiaryDesign.black)
                    .frame(maxWidth: .infinity)
                
                Button(action: {
                    weekOffset += 1
                    // Snap selected date to Monday of new week
                    state.selectedPlanDate = weekStart
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(RingStepperButtonStyle())
            }
            
            // Day pills
            HStack(spacing: 6) {
                ForEach(weekDays, id: \.self) { day in
                    dayPill(for: day)
                }
            }
        }
    }
    
    @ViewBuilder
    func dayPill(for day: Date) -> some View {
        let isSelected = Calendar.current.isDate(day, inSameDayAs: state.selectedPlanDate)
        let isToday = Calendar.current.isDateInToday(day)
        let (hasData, totalCal) = state.hasMealData(for: day)
        let isOver = totalCal > state.targetCalories
        
        Button(action: {
            state.selectedPlanDate = day
        }) {
            VStack(spacing: 3) {
                // Day of week
                Text(dayOfWeekShort(day))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? .white : FoodiaryDesign.mutedFg)
                    .textCase(.uppercase)
                
                // Date number
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .foregroundColor(isSelected ? .white : FoodiaryDesign.black)
                
                // Dot indicator
                Circle()
                    .fill(dotColor(hasData: hasData, isOver: isOver))
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 2)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? FoodiaryDesign.accent : (isToday ? FoodiaryDesign.muted : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isToday && !isSelected ? FoodiaryDesign.border : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func dotColor(hasData: Bool, isOver: Bool) -> Color {
        if !hasData { return .clear }
        return isOver ? FoodiaryDesign.accent : FoodiaryDesign.secondary
    }
    
    func dayOfWeekShort(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "E"
        return f.string(from: date)
    }
    
    // MARK: - Day Detail
    
    var dayDetailSection: some View {
        Group {
            if let plan = state.planDateMealPlan {
                populatedDayDetail(plan: plan)
            } else {
                emptyDayDetail
            }
        }
    }
    
    func populatedDayDetail(plan: MealPlan) -> some View {
        let totalCal = plan.totalCalories
        let isReadOnly = state.isPlanDatePast
        
        return VStack(spacing: 12) {
            // Day header
            dayHeader(totalCal: totalCal, isReadOnly: isReadOnly)
            
            // Progress bar
            RingProgressBar(
                progress: state.planDateProgress,
                isOver: state.isPlanDateOver
            )
            
            // Status badge
            statusBadge
            
            // Meals label
            Text(L10n["label.meals"])
                .sectionLabel()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Meal cards
            ForEach(Array(plan.meals.enumerated()), id: \.element.id) { index, meal in
                if isReadOnly {
                    // Past: view-only, no navigation
                    PlanMealCardView(meal: meal)
                } else {
                    // Today/future: tappable
                    Button(action: {
                        selectedMealIndex = index
                        showMealDetail = true
                    }) {
                        PlanMealCardView(meal: meal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    func dayHeader(totalCal: Int, isReadOnly: Bool) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(fullDayName(state.selectedPlanDate))
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(FoodiaryDesign.black)
                Text("\(dateString(state.selectedPlanDate)) · \(totalCal) / \(state.targetCalories) kcal")
                    .font(.system(size: 13))
                    .foregroundColor(FoodiaryDesign.mutedFg)
            }
            
            Spacer()
            
            // Status pill
            if isReadOnly {
                Text("🔒 VIEW ONLY")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(FoodiaryDesign.mutedFg)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(FoodiaryDesign.muted))
                    .overlay(Capsule().stroke(FoodiaryDesign.border, lineWidth: 1))
            } else if state.isPlanDateToday {
                Text("TODAY")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: "1E40AF"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(FoodiaryDesign.accentLight))
                    .overlay(Capsule().stroke(Color(hex: "BFDBFE"), lineWidth: 1))
            } else {
                Text("PLANNING")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: "166534"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(FoodiaryDesign.secondaryLight))
                    .overlay(Capsule().stroke(Color(hex: "BBF7D0"), lineWidth: 1))
            }
        }
    }
    
    var statusBadge: some View {
        let (bg, text): (Color, String) = {
            if state.planDateCalories == 0 {
                return (FoodiaryDesign.muted, L10n["today.status.no_food"])
            } else if state.isPlanDateOver {
                return (Color(hex: "FEE2E2"), state.planDateStatusMessage.uppercased())
            } else {
                return (FoodiaryDesign.secondaryLight, state.planDateStatusMessage.uppercased())
            }
        }()
        return Text(text).ringBadge(bg: bg)
    }
    
    @ViewBuilder
    var emptyDayDetail: some View {
        let isReadOnly = state.isPlanDatePast
        
        VStack(spacing: 12) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(fullDayName(state.selectedPlanDate))
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(FoodiaryDesign.black)
                    Text(dateString(state.selectedPlanDate))
                        .font(.system(size: 13))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                }
                
                Spacer()
                
                if isReadOnly {
                    Text("🔒 VIEW ONLY")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(FoodiaryDesign.muted))
                        .overlay(Capsule().stroke(FoodiaryDesign.border, lineWidth: 1))
                } else {
                    Text("PLANNING")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: "166534"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(FoodiaryDesign.secondaryLight))
                        .overlay(Capsule().stroke(Color(hex: "BBF7D0"), lineWidth: 1))
                }
            }
            
            if isReadOnly {
                // Past day with no data
                VStack(spacing: 12) {
                    Text("📋")
                        .font(.system(size: 40))
                        .opacity(0.4)
                    Text(L10n["plan.empty.past.title"])
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(FoodiaryDesign.black)
                    Text(L10n["plan.empty.past.subtitle"])
                        .font(.system(size: 13))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                // Future/today with no plan — show editable slots
                VStack(spacing: 12) {
                    VStack(spacing: 8) {
                        Text("📝")
                            .font(.system(size: 40))
                            .opacity(0.4)
                        Text(L10n["plan.empty.future.title"])
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(FoodiaryDesign.black)
                        Text(L10n["plan.empty.future.subtitle"])
                            .font(.system(size: 13))
                            .foregroundColor(FoodiaryDesign.mutedFg)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    
                    Text(L10n["label.meals"])
                        .sectionLabel()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(Meal.MealType.allCases, id: \.self) { type in
                        Button(action: {
                            createPlanAndAddFood(type: type)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: type.icon)
                                    .font(.system(size: 16))
                                    .frame(width: 40, height: 40)
                                    .ringCardColored(bg: iconBg(for: type), cornerRadius: 8)
                                    .frame(width: 44, height: 44)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(type.localizedDisplayName.uppercased())
                                        .font(FoodiaryTypography.bodyBold)
                                        .foregroundColor(FoodiaryDesign.black)
                                    Text(L10n["food.item_count", 0])
                                        .font(.system(size: 12))
                                        .foregroundColor(FoodiaryDesign.mutedFg)
                                }
                                
                                Spacer()
                                
                                Text("0 \(L10n["unit.kcal"])")
                                    .font(FoodiaryTypography.bodyBold)
                                    .foregroundColor(FoodiaryDesign.black)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(FoodiaryDesign.mutedFg)
                            }
                            .ringCardCompact()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    func createPlanAndAddFood(type: Meal.MealType) {
        // Create the meal plan if it doesn't exist
        if state.planDateMealPlan == nil {
            state.createMealPlan(for: state.selectedPlanDate)
        }
        // Find the meal index
        guard let plan = state.planDateMealPlan,
              let index = plan.meals.firstIndex(where: { $0.type == type }) else { return }
        selectedMealIndex = index
        showMealDetail = true
    }
    
    // MARK: - Helpers
    
    func fullDayName(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: date)
    }
    
    func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }
    
    func iconBg(for type: Meal.MealType) -> Color {
        switch type {
        case .breakfast: return Color(hex: "EFF6FF")
        case .lunch: return Color(hex: "ECFDF5")
        case .snack: return Color(hex: "FDF2F8")
        case .dinner: return Color(hex: "F5F3FF")
        }
    }
}

// MARK: - Plan Meal Card (reusable)

struct PlanMealCardView: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: meal.type.icon)
                .font(.system(size: 16))
                .frame(width: 40, height: 40)
                .ringCardColored(bg: iconBg, cornerRadius: 8)
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.type.localizedDisplayName.uppercased())
                    .font(FoodiaryTypography.bodyBold)
                    .foregroundColor(FoodiaryDesign.black)
                Text(L10n["food.item_count", meal.itemCount])
                    .font(.system(size: 12))
                    .foregroundColor(FoodiaryDesign.mutedFg)
            }
            
            Spacer()
            
            Text("\(meal.totalCalories) \(L10n["unit.kcal"])")
                .font(FoodiaryTypography.bodyBold)
                .foregroundColor(FoodiaryDesign.black)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(FoodiaryDesign.mutedFg)
        }
        .ringCardCompact()
    }
    
    var iconBg: Color {
        switch meal.type {
        case .breakfast: return Color(hex: "EFF6FF")
        case .lunch: return Color(hex: "ECFDF5")
        case .snack: return Color(hex: "FDF2F8")
        case .dinner: return Color(hex: "F5F3FF")
        }
    }
}

// MARK: - Plan Meal Card (reusable)
