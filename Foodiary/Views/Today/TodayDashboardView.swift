import SwiftUI

struct TodayDashboardView: View {
    @ObservedObject var state: AppState
    var onCreateMealPlan: () -> Void
    var onTapMeal: (Int) -> Void
    
    var body: some View {
        ScrollView {
            if state.hasTodayMealPlan, let plan = state.todayMealPlan {
                VStack(spacing: 16) {
                    // Target card
                    VStack(spacing: 8) {
                        Text("DAILY TARGET")
                            .sectionLabel()
                        Text("\(state.targetCalories)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(FoodiaryDesign.coral)
                        Text("kcal")
                            .font(FoodiaryTypography.bodySm)
                            .foregroundColor(FoodiaryDesign.mutedFg)
                        
                        NBProgressBar(progress: state.calorieProgress, isOver: state.isOverTarget)
                    }
                    .nbCard()
                    
                    // Planned / Remaining
                    HStack(spacing: 12) {
                        SummaryBox(
                            value: "\(state.plannedCalories)",
                            label: "PLANNED",
                            color: FoodiaryDesign.coral
                        )
                        SummaryBox(
                            value: "\(abs(state.remainingCalories))",
                            label: state.isOverTarget ? "OVER" : "REMAINING",
                            color: state.isOverTarget ? FoodiaryDesign.coral : FoodiaryDesign.mint
                        )
                    }
                    
                    // Status badge
                    statusBadge
                    
                    // Meals
                    Text("MEALS")
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
                VStack(spacing: 16) {
                    Spacer().frame(height: 80)
                    Text("📋")
                        .font(.system(size: 48))
                        .opacity(0.6)
                    Text("No meal plan for today")
                        .font(FoodiaryTypography.title)
                        .foregroundColor(FoodiaryDesign.black)
                    Text("Create one to start tracking your planned calories.")
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
    
    var statusBadge: some View {
        let (bg, text): (Color, String) = {
            if state.plannedCalories == 0 {
                return (FoodiaryDesign.muted, "NO FOOD PLANNED YET")
            } else if state.isExactlyAtTarget {
                return (Color(hex: "FEF9C3"), "EXACTLY AT YOUR TARGET")
            } else if state.isOverTarget {
                return (Color(hex: "FEE2E2"), state.statusMessage.uppercased())
            } else {
                return (Color(hex: "D1FAE5"), state.statusMessage.uppercased())
            }
        }()
        
        return Text(text).nbBadge(bg: bg)
    }
}

struct SummaryBox: View {
    let value: String
    let label: String
    var color: Color = FoodiaryDesign.black
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(FoodiaryTypography.metric)
                .foregroundColor(color)
            Text(label)
                .font(FoodiaryTypography.label)
                .foregroundColor(FoodiaryDesign.mutedFg)
        }
        .frame(maxWidth: .infinity)
        .nbCardCompact(cornerRadius: 16, shadowOffset: CGSize(width: 3, height: 3))
    }
}

struct MealCardView: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: meal.type.icon)
                .font(.system(size: 18))
                .frame(width: 44, height: 44)
                .nbCardColored(
                    bg: iconBg,
                    cornerRadius: 8,
                    shadowOffset: CGSize(width: 2, height: 2),
                    borderWidth: 2,
                    padding: 0
                )
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.type.displayName.uppercased())
                    .font(FoodiaryTypography.bodyBold)
                    .foregroundColor(FoodiaryDesign.black)
                Text("\(meal.itemCount) item\(meal.itemCount == 1 ? "" : "s")")
                    .font(.system(size: 12))
                    .foregroundColor(FoodiaryDesign.mutedFg)
            }
            
            Spacer()
            
            Text("\(meal.totalCalories) kcal")
                .font(FoodiaryTypography.bodyBold)
                .foregroundColor(FoodiaryDesign.black)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(FoodiaryDesign.black)
        }
        .nbCardCompact()
    }
    
    var iconBg: Color {
        switch meal.type {
        case .breakfast: return Color(hex: "FFF3E0")
        case .lunch: return Color(hex: "E0F7FA")
        case .snack: return Color(hex: "FCE4EC")
        case .dinner: return Color(hex: "E8EAF6")
        }
    }
}
