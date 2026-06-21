import SwiftUI

struct TodayDashboardView: View {
    @ObservedObject var state: AppState
    var onCreateMealPlan: () -> Void
    var onTapMeal: (Int) -> Void
    
    var body: some View {
        ScrollView {
            if state.hasTodayMealPlan, let plan = state.todayMealPlan {
                VStack(spacing: 16) {
                    // Progress ring
                    ringSection
                    
                    // Planned / Remaining tiles
                    HStack(spacing: 12) {
                        SummaryTile(
                            value: "\(state.plannedCalories)",
                            label: L10n["label.planned"],
                            color: FoodiaryDesign.accent
                        )
                        SummaryTile(
                            value: "\(abs(state.remainingCalories))",
                            label: state.isOverTarget ? L10n["label.over"] : L10n["label.remaining"],
                            color: state.isOverTarget ? FoodiaryDesign.accent : FoodiaryDesign.secondary
                        )
                    }
                    
                    // Status badge
                    statusBadge
                    
                    // Macro bars
                    if state.plannedCalories > 0 {
                        macroSection
                    }
                    
                    // Meals
                    Text(L10n["label.meals"])
                        .sectionLabel()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(Array(plan.meals.enumerated()), id: \.element.id) { index, meal in
                        Button(action: { onTapMeal(index) }) {
                            MealCardView(meal: meal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(20)
            } else {
                emptyState
            }
        }
        .background(FoodiaryDesign.background)
    }
    
    // MARK: - Ring Section
    
    var ringSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RingProgressView(
                    progress: state.calorieProgress,
                    isOver: state.isOverTarget
                )
                VStack(spacing: 4) {
                    Text("\(state.plannedCalories)")
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundColor(FoodiaryDesign.black)
                    Text("of \(state.targetCalories) kcal".uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .ringCard(cornerRadius: 20)
    }
    
    // MARK: - Macro Section
    
    var macroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n["label.macronutrients"])
                .sectionLabel()
            MacroBar(label: "Protein", value: state.totalProtein, maxValue: state.maxMacro, color: Color(hex: "2563EB"))
            MacroBar(label: "Carbs", value: state.totalCarbs, maxValue: state.maxMacro, color: Color(hex: "D97706"))
            MacroBar(label: "Fat", value: state.totalFat, maxValue: state.maxMacro, color: Color(hex: "DC2626"))
        }
        .ringCardCompact()
    }
    
    // MARK: - Status Badge
    
    var statusBadge: some View {
        let (bg, text): (Color, String) = {
            if state.plannedCalories == 0 {
                return (FoodiaryDesign.muted, L10n["today.status.no_food"])
            } else if state.isExactlyAtTarget {
                return (FoodiaryDesign.warningLight, L10n["today.status.exact"])
            } else if state.isOverTarget {
                return (Color(hex: "FEE2E2"), state.localizedStatusMessage.uppercased())
            } else {
                return (FoodiaryDesign.secondaryLight, state.localizedStatusMessage.uppercased())
            }
        }()
        return Text(text).ringBadge(bg: bg)
    }
    
    // MARK: - Empty State
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 80)
            Text("📋")
                .font(.system(size: 48))
                .opacity(0.5)
            Text(L10n["today.empty.title"])
                .font(FoodiaryTypography.title)
                .foregroundColor(FoodiaryDesign.black)
            Text(L10n["today.empty.subtitle"])
                .font(FoodiaryTypography.body)
                .foregroundColor(FoodiaryDesign.mutedFg)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button(action: onCreateMealPlan) {
                Text(L10n["action.create_meal_plan"])
            }
            .buttonStyle(RingButtonStyle())
            .frame(width: 220)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
    }
}

// MARK: - Summary Tile

struct SummaryTile: View {
    let value: String
    let label: String
    var color: Color = FoodiaryDesign.black
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(color)
            Text(label)
                .font(FoodiaryTypography.label)
                .foregroundColor(FoodiaryDesign.mutedFg)
        }
        .frame(maxWidth: .infinity)
        .ringCardCompact()
    }
}

// MARK: - Meal Card

struct MealCardView: View {
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
