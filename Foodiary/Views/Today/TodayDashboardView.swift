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
                    heroSection(plan: plan)
                    macroGrid
                    actionStrip(plan: plan)
                    mealTimeline(plan: plan)
                }
                .padding(18)
            } else {
                emptyState
            }
        }
        .background(FoodiaryDesign.pulseBackground)
    }

    // MARK: - Hero

    private func heroSection(plan: MealPlan) -> some View {
        let remaining = state.remainingCalories
        let pct = Int(state.calorieProgress * 100)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("REMAINING ESTIMATE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white.opacity(0.72))
                        .tracking(1.0)

                    Text("\(max(0, remaining))")
                        .font(.system(size: 66, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(-2)
                        .padding(.top, 12)

                    Text("kcal available today")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.78))
                        .padding(.top, 4)
                }

                Spacer()

                Text("⚡ \(pct)% used")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.white.opacity(0.16)))
            }

            Text("\(state.plannedCalories) kcal planned against a \(state.targetCalories) kcal estimate. \(nextActionSuggestion(plan: plan))")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.84))
                .lineSpacing(4)
                .frame(maxWidth: 270, alignment: .leading)
                .padding(.top, 16)

            HStack(spacing: 4) {
                ForEach(Array(plan.meals.enumerated()), id: \.element.type.rawValue) { index, meal in
                    Button { onTapMeal(index) } label: {
                        Capsule()
                            .fill(.white.opacity(segmentOpacity(index, meal: meal, plan: plan)))
                            .frame(height: 14)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 17)
        }
        .padding(19)
        .background(
            ZStack {
                // Soft blue gradient base
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "93C5FD"), Color(hex: "60A5FA"), Color(hex: "3B82F6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Aurora animated blobs
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSince1970
                    ZStack {
                        auroraBlob(color: Color(hex: "8B5CF6"), size: CGSize(width: 180, height: 140),
                                   offset: CGPoint(x: sin(t * 0.3) * 50 - 30, y: cos(t * 0.4) * 40 - 40), blur: 35)
                        auroraBlob(color: Color(hex: "60A5FA"), size: CGSize(width: 160, height: 120),
                                   offset: CGPoint(x: cos(t * 0.35) * 60 + 20, y: sin(t * 0.45) * 45 - 15), blur: 30)
                        auroraBlob(color: Color(hex: "22D3EE"), size: CGSize(width: 200, height: 150),
                                   offset: CGPoint(x: sin(t * 0.5) * 70 + 10, y: cos(t * 0.3) * 55 + 25), blur: 40)
                        auroraBlob(color: Color(hex: "34D399"), size: CGSize(width: 140, height: 110),
                                   offset: CGPoint(x: cos(t * 0.45) * 65 - 20, y: sin(t * 0.55) * 40 + 40), blur: 28)
                    }
                }

                // Radial highlight
                Circle()
                    .fill(RadialGradient(colors: [.white.opacity(0.25), .clear], center: .topLeading, startRadius: 0, endRadius: 200))
                    .offset(x: -30, y: -50)

                // Decorative circle
                Circle()
                    .fill(.white.opacity(0.14))
                    .frame(width: 180, height: 180)
                    .offset(x: 80, y: 120)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        )
        .shadow(color: Color(hex: "3B82F6").opacity(0.2), radius: 26, x: 0, y: 13)
    }

    private func auroraBlob(color: Color, size: CGSize, offset: CGPoint, blur: CGFloat) -> some View {
        Ellipse()
            .fill(color)
            .frame(width: size.width, height: size.height)
            .blur(radius: blur)
            .offset(x: offset.x, y: offset.y)
    }

    private func segmentOpacity(_ index: Int, meal: Meal, plan: MealPlan) -> Double {
        let total = plan.meals.reduce(0) { $0 + $1.totalCalories }
        guard total > 0 else { return 0.21 }
        let ratio = Double(meal.totalCalories) / Double(max(total, 1))
        return 0.21 + ratio * 0.79
    }

    private func nextActionSuggestion(plan: MealPlan) -> String {
        let empty = plan.meals.filter { $0.items.isEmpty }
        if let next = empty.first {
            return "\(next.type.localizedDisplayName) is the next adjustable slot."
        }
        return "All meals have entries — adjust as needed."
    }

    private func todayDateString() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.dateFormat = "EEEE, d MMMM yyyy"
        return f.string(from: Date()).uppercased()
    }

    // MARK: - Macro Grid (Glass morphism pills)

    private var macroGrid: some View {
        HStack(spacing: 10) {
            glassPill(value: "\(state.totalProtein)g", label: "Protein", tint: Color(hex: "2563EB"))
            glassPill(value: "\(state.totalCarbs)g", label: "Carbs", tint: Color(hex: "F59E0B"))
            glassPill(value: "\(state.totalFat)g", label: "Fat", tint: Color(hex: "EF4444"))
        }
    }

    private func glassPill(value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(FoodiaryDesign.pulseInk)
            Text(label)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(tint)
                .textCase(.uppercase)
                .tracking(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous).fill(tint.opacity(0.08))
                RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(tint.opacity(0.15), lineWidth: 1)
            }
        )
    }

    // MARK: - Action Strip

    private func actionStrip(plan: MealPlan) -> some View {
        let hasEmpty = plan.meals.contains { $0.items.isEmpty }
        return HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Next best action").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text(hasEmpty ? "Add or refine a meal before the plan is complete." : "All meals planned — review your estimates.")
                    .font(.system(size: 12)).foregroundColor(.white.opacity(0.64))
            }
            Spacer()
            Button { onTapMeal(plan.meals.firstIndex(where: { $0.items.isEmpty }) ?? 0) } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "15142A"))
                    .frame(width: 42, height: 42)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(.white))
            }
        }
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color(hex: "15142A")))
    }

    // MARK: - Meal Timeline

    private func mealTimeline(plan: MealPlan) -> some View {
        VStack(spacing: 11) {
            HStack {
                Text("MEAL TIMELINE").font(.system(size: 12, weight: .black)).foregroundColor(FoodiaryDesign.pulseInk).tracking(1.0)
                Spacer()
                Text("\(plan.meals.count) slots").font(.system(size: 12, weight: .black)).foregroundColor(FoodiaryDesign.pulsePrimary)
            }
            ForEach(Array(plan.meals.enumerated()), id: \.element.id) { index, meal in
                Button(action: { onTapMeal(index) }) {
                    HStack(spacing: 12) {
                        Text(meal.type == .breakfast ? "🍳" : meal.type == .lunch ? "🍱" : meal.type == .snack ? "🍌" : "🍽️")
                            .font(.system(size: 22)).frame(width: 50, height: 50)
                            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(FoodiaryDesign.pulseMealTint(for: meal.type)))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(meal.type.localizedDisplayName).font(.system(size: 14, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk)
                            Text(mealSubtitle(meal)).font(.system(size: 12)).foregroundColor(FoodiaryDesign.pulseMuted)
                        }
                        Spacer()
                        Text("\(meal.totalCalories) kcal").font(.system(size: 14, weight: .black)).foregroundColor(FoodiaryDesign.pulseInk)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 6)
    }

    private func mealSubtitle(_ meal: Meal) -> String {
        let count = meal.itemCount
        if count == 0 { return "Tap to add food" }
        return "\(count) \(count == 1 ? "item" : "items") · planned"
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
