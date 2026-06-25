import SwiftUI

// MARK: - Macro Grid
///
/// Glass morphism pills showing protein, carbs, and fat totals.

struct TodayMacroGrid: View {
    let totalProtein: Int
    let totalCarbs: Int
    let totalFat: Int

    var body: some View {
        HStack(spacing: 10) {
            glassPill(value: "\(totalProtein)g", label: "Protein", tint: Color(hex: "2563EB"))
            glassPill(value: "\(totalCarbs)g", label: "Carbs", tint: Color(hex: "F59E0B"))
            glassPill(value: "\(totalFat)g", label: "Fat", tint: Color(hex: "EF4444"))
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
}
