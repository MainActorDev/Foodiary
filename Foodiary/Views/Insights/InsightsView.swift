import SwiftUI

// MARK: - Insights View
//
// Shows real aggregated patterns from historical meal plan data:
// calorie trend chart, average metrics, macro distribution,
// per-meal-type averages, and derived observations.
// All data comes from InsightsService — no fake or random values.

struct InsightsView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    @Bindable var state: AppState

    @State private var selectedRangeDays: Int = 7
    private let ranges = [7, 14, 30]

    private var summary: InsightsSummary {
        state.insightsSummary(forDays: selectedRangeDays)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                PulseTopbar(
                    overline: L10n["insights.overline"],
                    title: L10n["nav.insights"],
                    icon: nil
                )

                rangePicker

                calorieTrendCard

                metricGrid

                if summary.hasData {
                    macroDistributionCard
                    mealTypeBreakdownCard
                }

                observationsSection
            }
            .padding(.horizontal, 18)
        }
        .background(FoodiaryDesign.pulseBackground)
    }

    // MARK: - Range picker

    private var rangePicker: some View {
        HStack(spacing: 0) {
            ForEach(ranges, id: \.self) { days in
                let label = rangeLabel(days)
                Text(label)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(selectedRangeDays == days ? .white : FoodiaryDesign.pulseMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(selectedRangeDays == days ? FoodiaryDesign.pulsePrimary : Color.clear)
                    )
            }
        }
        .padding(3)
        .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(FoodiaryDesign.pulseSurfaceSoft))
    }

    private func rangeLabel(_ days: Int) -> String {
        switch days {
        case 7: return L10n["insights.range.7d"]
        case 14: return L10n["insights.range.14d"]
        case 30: return L10n["insights.range.30d"]
        default: return ""
        }
    }

    // MARK: - Calorie trend chart

    private var calorieTrendCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L10n["insights.chart.title"])
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                Spacer()
                Text(L10n["insights.chart.target_line"])
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
            }

            if summary.dailyEntries.isEmpty {
                emptyChartState
            } else {
                calorieBars
            }
        }
        .padding(16)
        .pulseCard(cornerRadius: 26, padding: 0)
    }

    private var emptyChartState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar")
                .font(.system(size: 28))
                .foregroundColor(FoodiaryDesign.pulseMuted)
            Text(L10n["insights.chart.no_data"])
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(FoodiaryDesign.pulseMuted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
    }

    private var calorieBars: some View {
        let maxCal = max(
            summary.dailyEntries.map(\.calories).max() ?? 0,
            summary.targetCalories,
            1
        )

        return VStack(alignment: .leading, spacing: 6) {
            chartArea(maxCal: maxCal)
            dayLabels
        }
    }

    private func chartArea(maxCal: Int) -> some View {
        let formatter = dayLabelFormatter

        return GeometryReader { geo in
            let h = geo.size.height
            let targetY = h * (1 - CGFloat(summary.targetCalories) / CGFloat(maxCal))

            ZStack(alignment: .topLeading) {
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(summary.dailyEntries, id: \.date) { entry in
                        barForEntry(entry, maxHeight: h, maxCal: maxCal)
                    }
                }

                DashedTargetLine()
                    .stroke(FoodiaryDesign.pulsePrimary.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                    .frame(height: 1.5)
                    .offset(y: targetY)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 130)
    }

    private func barForEntry(_ entry: DailyCalorieEntry, maxHeight: CGFloat, maxCal: Int) -> some View {
        let heightRatio = maxCal > 0 ? CGFloat(entry.calories) / CGFloat(maxCal) : 0
        let barHeight = entry.hasFood ? max(4, maxHeight * heightRatio) : 3
        let barColor = entry.isOverTarget ? FoodiaryDesign.pulseAmber : FoodiaryDesign.pulsePrimary

        return VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    entry.hasFood
                        ? LinearGradient(colors: [barColor, FoodiaryDesign.pulseCyan], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [FoodiaryDesign.pulseBorder], startPoint: .top, endPoint: .bottom)
                )
                .frame(maxWidth: 20)
                .frame(height: barHeight)
        }
        .frame(maxWidth: .infinity)
    }

    private var dayLabels: some View {
        let formatter = dayLabelFormatter

        return HStack(spacing: 0) {
            ForEach(summary.dailyEntries, id: \.date) { entry in
                Text(formatter.string(from: entry.date).uppercased())
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(entry.isToday ? FoodiaryDesign.pulsePrimary : FoodiaryDesign.pulseMuted)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var dayLabelFormatter: DateFormatter {
        let f = DateFormatter.dayOfWeekShort
        f.locale = Locale(identifier: localeManager.selectedLanguage)
        return f
    }

    // MARK: - Metric grid

    private var metricGrid: some View {
        HStack(spacing: 10) {
            metricTile(
                value: avgCaloriesLabel,
                label: L10n["insights.metrics.avg_calories"]
            )
            metricTile(
                value: "\(summary.loggedDays)",
                label: L10n["insights.metrics.logged_days"]
            )
            metricTile(
                value: summary.hasData ? "\(summary.consistencyPercent)%" : "—",
                label: L10n["insights.metrics.consistency"]
            )
        }
    }

    private var avgCaloriesLabel: String {
        guard summary.averageCalories > 0 else { return "—" }
        let whole = summary.averageCalories / 1000
        let remainder = summary.averageCalories % 1000
        if remainder >= 500 {
            return "\(whole).5k"
        } else {
            return "\(whole)k"
        }
    }

    private func metricTile(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(FoodiaryDesign.pulseInk)
            Text(label)
                .pulseSectionLabel()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(FoodiaryDesign.pulseSurfaceSoft))
    }

    // MARK: - Macro distribution

    private var macroDistributionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n["insights.macros.title"])
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(FoodiaryDesign.pulseInk)

            macroBar

            HStack(spacing: 16) {
                macroLabel(color: FoodiaryDesign.pulsePrimary, name: L10n["insights.macros.protein"], grams: summary.macroBreakdown.avgProtein)
                macroLabel(color: FoodiaryDesign.pulseMint, name: L10n["insights.macros.carbs"], grams: summary.macroBreakdown.avgCarbs)
                macroLabel(color: FoodiaryDesign.pulseAmber, name: L10n["insights.macros.fat"], grams: summary.macroBreakdown.avgFat)
            }
        }
        .padding(16)
        .pulseCard(cornerRadius: 26, padding: 0)
    }

    private var macroBar: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let proteinW = w * summary.macroBreakdown.proteinPercent
            let carbsW = w * summary.macroBreakdown.carbsPercent
            let fatW = w * summary.macroBreakdown.fatPercent

            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(FoodiaryDesign.pulsePrimary)
                    .frame(width: max(2, proteinW))
                RoundedRectangle(cornerRadius: 4)
                    .fill(FoodiaryDesign.pulseMint)
                    .frame(width: max(2, carbsW))
                RoundedRectangle(cornerRadius: 4)
                    .fill(FoodiaryDesign.pulseAmber)
                    .frame(width: max(2, fatW))
            }
        }
        .frame(height: 12)
    }

    private func macroLabel(color: Color, name: String, grams: Int) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                Text(L10n["insights.macros.grams", grams])
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
            }
        }
    }

    // MARK: - Meal type breakdown

    private var mealTypeBreakdownCard: some View {
        let maxAvg = summary.mealTypeBreakdown.values.map(\.averageCalories).max() ?? 1

        return VStack(alignment: .leading, spacing: 14) {
            Text(L10n["insights.mealtype.title"])
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(FoodiaryDesign.pulseInk)

            ForEach(Meal.MealType.allCases, id: \.rawValue) { mealType in
                if let avg = summary.mealTypeBreakdown[mealType], avg.averageCalories > 0 {
                    mealTypeRow(avg, maxAvg: maxAvg)
                }
            }
        }
        .padding(16)
        .pulseCard(cornerRadius: 26, padding: 0)
    }

    private func mealTypeRow(_ avg: MealTypeAverage, maxAvg: Int) -> some View {
        let ratio = maxAvg > 0 ? CGFloat(avg.averageCalories) / CGFloat(maxAvg) : 0

        return HStack(spacing: 12) {
            Text(avg.type.emoji)
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(FoodiaryDesign.pulseMealTint(for: avg.type)))

            VStack(alignment: .leading, spacing: 2) {
                Text(avg.type.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                Text("\(avg.averageCalories) kcal")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 3)
                .fill(FoodiaryDesign.pulseMealAccent(for: avg.type))
                .frame(width: max(8, 50 * ratio), height: 6)
        }
    }

    // MARK: - Observations

    private var observationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n["insights.observations.title"])
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                Spacer()
                Text(L10n["insights.observations.neutral"])
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
            }

            VStack(spacing: 10) {
                ForEach(summary.observations) { obs in
                    observationRow(obs)
                }
            }
        }
    }

    private func observationRow(_ obs: InsightObservation) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: obs.icon)
                .font(.system(size: 16))
                .foregroundColor(FoodiaryDesign.pulsePrimary)
                .frame(width: 32, height: 32)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(FoodiaryDesign.pulseSurfaceSoft))

            VStack(alignment: .leading, spacing: 3) {
                Text(obs.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                Text(obs.detail)
                    .font(.system(size: 12))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(FoodiaryDesign.pulseSurfaceSoft))
    }
}

// MARK: - Dashed target line shape

private struct DashedTargetLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}
