import SwiftUI

// MARK: - Insights View
///
/// Extracted from MainTabView.swift — now in its own file.

struct InsightsView: View {
    @Bindable var state: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                PulseTopbar(overline: "NEUTRAL PATTERNS", title: L10n["nav.insights"], icon: .chart)
                chartCard
                metricGrid
                observationsSection
            }
            .padding(.horizontal, 18)
        }
        .background(FoodiaryDesign.pulseBackground)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Planned calories this week")
                .font(.system(size: 13, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk)
            HStack(alignment: .bottom, spacing: 9) {
                ForEach(weekChartData, id: \.day) { item in
                    VStack(spacing: 7) {
                        RoundedRectangle(cornerRadius: 999)
                            .fill(LinearGradient(colors: [FoodiaryDesign.pulsePrimary, Color(hex: "06B6D4")], startPoint: .top, endPoint: .bottom))
                            .frame(maxWidth: 24, maxHeight: 124).frame(height: item.height)
                        Text(item.day).font(.system(size: 9, weight: .black)).foregroundColor(FoodiaryDesign.pulseMuted).textCase(.uppercase)
                    }
                }
            }.frame(height: 140)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(FoodiaryDesign.pulseSurface).shadow(color: Color(hex: "141428").opacity(0.055), radius: 30, x: 0, y: 14))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(Color(hex: "15142A").opacity(0.10), lineWidth: 1))
    }

    private var weekChartData: [(day: String, height: CGFloat)] {
        let days = ["M","T","W","T","F","S","S"]; let today = state.plannedCalories
        let heights: [CGFloat] = days.indices.map { i in i == 6 ? min(124, CGFloat(today) / 30.0) : CGFloat.random(in: 20...124) }
        return Array(zip(days, heights))
    }

    private var metricGrid: some View {
        HStack(spacing: 10) {
            insightMetric(value: "\(state.plannedCalories > 0 ? 1 : 0)", label: "Logged days")
            insightMetric(value: state.plannedCalories > 0 ? "\(state.plannedCalories / 1000)k" : "—", label: "Avg kcal")
            insightMetric(value: "\(max(0, state.remainingCalories))", label: "Avg room")
        }
    }

    private func insightMetric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(FoodiaryDesign.pulseInk)
            Text(label).font(.system(size: 11, weight: .black)).foregroundColor(FoodiaryDesign.pulseMuted).textCase(.uppercase).tracking(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(14)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(FoodiaryDesign.pulseSurfaceSoft))
    }

    private var observationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text("OBSERVATIONS").font(.system(size: 13, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk); Spacer(); Text("Neutral").font(.system(size: 12, weight: .medium)).foregroundColor(FoodiaryDesign.pulseMuted) }
            VStack(spacing: 10) { insightRow(title: observationA, detail: observationADetail); insightRow(title: observationB, detail: observationBDetail); insightRow(title: observationC, detail: observationCDetail) }
        }
    }
    private var observationA: String { state.plannedCalories > 0 ? "You logged food today." : "No meals logged yet today." }
    private var observationADetail: String { state.totalProtein > 0 ? "Protein entries are present in today's log." : "Start by adding a meal to begin tracking." }
    private var observationB: String { let e = state.todayMealPlan?.meals.filter { $0.items.isEmpty }.count ?? 4; return e > 0 ? "\(e) meal slots are still open today." : "All meals are planned for today." }
    private var observationBDetail: String { "Plan empty slots when you are ready; no action is required now." }
    private var observationC: String { if state.isOverTarget { "You are above your estimated target." } else if state.remainingCalories > 0 { "You have room in your planning estimate." } else { "You are exactly at your estimated target." } }
    private var observationCDetail: String { state.isOverTarget ? "Adjust future meals or review your portions." : "Your current plan aligns with your planning preference." }
    private func insightRow(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) { Text(title).font(.system(size: 13, weight: .bold)).foregroundColor(FoodiaryDesign.pulseInk); Text(detail).font(.system(size: 12)).foregroundColor(FoodiaryDesign.pulseMuted) }
            .frame(maxWidth: .infinity, alignment: .leading).padding(13).background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(FoodiaryDesign.pulseSurfaceSoft))
    }
}
