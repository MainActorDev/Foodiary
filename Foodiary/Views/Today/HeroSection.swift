import SwiftUI

// MARK: - Hero Section
///
/// The hero card showing remaining estimate, progress chip,
/// contextual copy, and meal segments.

struct TodayHeroSection: View {
    let remainingCalories: Int
    let calorieProgress: Double
    let plannedCalories: Int
    let targetCalories: Int
    let plan: MealPlan
    let todayDateString: String
    var onTapMeal: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(L10n["today.hero.remaining_estimate"])
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white.opacity(0.72))
                        .tracking(1.0)

                    Text("\(max(0, remainingCalories))")
                        .font(.system(size: 66, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(-2)
                        .padding(.top, 12)

                    Text(L10n["today.hero.kcal_available"])
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.78))
                        .padding(.top, 4)
                }

                Spacer()

                Text(L10n["today.hero.percent_used", Int(calorieProgress * 100)])
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.white.opacity(0.16)))
            }

            Text(L10n["today.hero.planned_summary", plannedCalories, targetCalories])
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.84))
                .lineSpacing(4)
                .frame(maxWidth: 270, alignment: .leading)
                .padding(.top, 16)

            Text(suggestion)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.64))
                .padding(.top, 6)

            HStack(spacing: 4) {
                ForEach(Array(plan.meals.enumerated()), id: \.element.type.rawValue) { index, meal in
                    Button { onTapMeal(index) } label: {
                        Capsule()
                            .fill(.white.opacity(segmentOpacity(index, meal: meal)))
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
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "93C5FD"), Color(hex: "60A5FA"), Color(hex: "3B82F6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
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
                Circle()
                    .fill(RadialGradient(colors: [.white.opacity(0.25), .clear], center: .topLeading, startRadius: 0, endRadius: 200))
                    .offset(x: -30, y: -50)
                Circle()
                    .fill(.white.opacity(0.14))
                    .frame(width: 180, height: 180)
                    .offset(x: 80, y: 120)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        )
        .shadow(color: Color(hex: "3B82F6").opacity(0.2), radius: 26, x: 0, y: 13)
    }

    private var suggestion: String {
        let empty = plan.meals.filter { $0.items.isEmpty }
        if let next = empty.first {
            return L10n["today.hero.suggestion_format", next.type.displayName]
        }
        return L10n["today.hero.suggestion_all_done"]
    }

    private func segmentOpacity(_ index: Int, meal: Meal) -> Double {
        let total = plan.meals.reduce(0) { $0 + $1.totalCalories }
        guard total > 0 else { return 0.21 }
        let ratio = Double(meal.totalCalories) / Double(max(total, 1))
        return 0.21 + ratio * 0.79
    }

    private func auroraBlob(color: Color, size: CGSize, offset: CGPoint, blur: CGFloat) -> some View {
        Ellipse()
            .fill(color)
            .frame(width: size.width, height: size.height)
            .blur(radius: blur)
            .offset(x: offset.x, y: offset.y)
    }
}
