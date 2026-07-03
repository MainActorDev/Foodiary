import SwiftUI

// MARK: - Week Summary

struct WeekSummary: View {
    @EnvironmentObject private var localeManager: LocaleManager
    let plannedDays: Int
    let totalDays: Int

    var body: some View {
        HStack(spacing: 10) {
            metricBox(value: "\(plannedDays)/\(totalDays)", label: L10n["plan.days_planned"])
            metricBox(value: "\(totalDays - plannedDays)", label: L10n["plan.open_days"])
        }
    }

    private func metricBox(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(FoodiaryDesign.pulseInk)
            Text(label).font(.system(size: 11, weight: .black)).foregroundColor(FoodiaryDesign.pulseMuted).textCase(.uppercase).tracking(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(14)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(FoodiaryDesign.pulseSurfaceSoft))
    }
}
