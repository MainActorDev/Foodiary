import SwiftUI

// MARK: - Action Strip
///
/// Dark strip at the bottom of the Today screen with a suggestion
/// and a floating "+" button.

struct TodayActionStrip: View {
    @EnvironmentObject private var localeManager: LocaleManager
    let plan: MealPlan
    var onTapMeal: (Int) -> Void

    private var hasEmpty: Bool {
        plan.meals.contains { $0.items.isEmpty }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(L10n["today.action.next_best"]).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text(hasEmpty
                     ? L10n["today.action.add_or_refine"]
                     : L10n["today.action.all_planned"])
                    .font(.system(size: 12)).foregroundColor(.white.opacity(0.64))
            }
            Spacer()
            Button {
                onTapMeal(plan.meals.firstIndex(where: { $0.items.isEmpty }) ?? 0)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                    .frame(width: 42, height: 42)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(.white))
            }
        }
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(FoodiaryDesign.pulseInk))
    }
}
