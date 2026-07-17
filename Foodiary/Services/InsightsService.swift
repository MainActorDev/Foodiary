import Foundation
import SwiftData

/// Computes aggregate insights from historical MealPlan data.
///
/// Fetches MealPlans in a date range via ``PersistenceService`` then
/// derives patterns: daily calorie entries, averages, streaks, consistency,
/// macro distribution, per-meal-type averages, and contextual observations
/// — all from real user data.
@MainActor
final class InsightsService {
    private let persistence: any PersistenceService

    init(persistence: any PersistenceService) {
        self.persistence = persistence
    }

    // MARK: - Public API

    /// Compute insights for the last `days` days (including today).
    func summary(forDays days: Int, targetCalories: Double) -> InsightsSummary {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: today) else {
            return emptySummary(days: days, targetCalories: targetCalories)
        }

        let plans = fetchMealPlans(from: startDate, to: today)
        let dailyEntries = buildDailyEntries(
            from: plans,
            startDate: startDate,
            endDate: today,
            targetCalories: targetCalories
        )

        let loggedEntries = dailyEntries.filter { $0.hasFood }
        let loggedDays = loggedEntries.count
        let totalCalories = loggedEntries.reduce(0) { $0 + $1.calories }
        let averageCalories = loggedDays > 0 ? totalCalories / loggedDays : 0
        let averageRemaining = Int(targetCalories) - averageCalories

        let macroBreakdown = computeMacroBreakdown(from: plans, loggedDays: loggedDays)
        let mealTypeBreakdown = computeMealTypeBreakdown(plans: plans, totalDays: days)
        let loggingStreak = computeStreak(entries: dailyEntries)
        let consistencyPercent = computeConsistency(loggedEntries: loggedEntries, target: targetCalories)
        let observations = generateObservations(
            loggedDays: loggedDays,
            totalDays: days,
            consistency: consistencyPercent,
            streak: loggingStreak,
            mealTypeBreakdown: mealTypeBreakdown
        )

        return InsightsSummary(
            dailyEntries: dailyEntries,
            loggedDays: loggedDays,
            totalDaysInRange: days,
            averageCalories: averageCalories,
            averageRemaining: averageRemaining,
            targetCalories: targetCalories,
            macroBreakdown: macroBreakdown,
            mealTypeBreakdown: mealTypeBreakdown,
            loggingStreak: loggingStreak,
            consistencyPercent: consistencyPercent,
            observations: observations,
            hasData: loggedDays > 0
        )
    }

    // MARK: - Fetch

    /// Fetch all MealPlans whose date falls within [start, end] (inclusive, day-level).
    private func fetchMealPlans(from start: Date, to end: Date) -> [MealPlan] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: start)
        guard let endOfRange = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end)) else {
            return []
        }
        let descriptor = FetchDescriptor<MealPlan>(
            predicate: #Predicate { plan in
                plan.date >= startOfDay && plan.date < endOfRange
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? persistence.fetch(descriptor)) ?? []
    }

    // MARK: - Daily entries

    /// Build one entry per calendar day in the range.
    /// Days without a plan or with an empty plan get a zero-calorie entry.
    private func buildDailyEntries(
        from plans: [MealPlan],
        startDate: Date,
        endDate: Date,
        targetCalories: Double
    ) -> [DailyCalorieEntry] {
        let calendar = Calendar.current

        // Index plans by start-of-day for O(1) lookup
        var planByDay: [Date: MealPlan] = [:]
        for plan in plans {
            planByDay[calendar.startOfDay(for: plan.date)] = plan
        }

        var entries: [DailyCalorieEntry] = []
        var current = startDate
        while current <= endDate {
            let plan = planByDay[calendar.startOfDay(for: current)]
            let hasFood = plan?.meals.contains { !$0.items.isEmpty } ?? false
            let calories = plan?.totalCalories ?? 0
            entries.append(DailyCalorieEntry(
                date: current,
                calories: calories,
                targetCalories: targetCalories,
                isToday: calendar.isDateInToday(current),
                hasFood: hasFood
            ))
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return entries
    }

    // MARK: - Macro breakdown

    private func computeMacroBreakdown(from plans: [MealPlan], loggedDays: Int) -> MacroBreakdown {
        guard loggedDays > 0 else {
            return MacroBreakdown(avgProtein: 0, avgCarbs: 0, avgFat: 0, totalGrams: 0)
        }
        var totalProtein = 0, totalCarbs = 0, totalFat = 0
        for plan in plans {
            guard plan.meals.contains(where: { !$0.items.isEmpty }) else { continue }
            for meal in plan.meals {
                for item in meal.items {
                    totalProtein += item.protein
                    totalCarbs += item.carbs
                    totalFat += item.fat
                }
            }
        }
        let avgProtein = totalProtein / loggedDays
        let avgCarbs = totalCarbs / loggedDays
        let avgFat = totalFat / loggedDays
        return MacroBreakdown(
            avgProtein: avgProtein,
            avgCarbs: avgCarbs,
            avgFat: avgFat,
            totalGrams: avgProtein + avgCarbs + avgFat
        )
    }

    // MARK: - Meal type breakdown

    private func computeMealTypeBreakdown(plans: [MealPlan], totalDays: Int) -> [Meal.MealType: MealTypeAverage] {
        var calorieSums: [Meal.MealType: Int] = [:]
        var loggedCounts: [Meal.MealType: Int] = [:]

        for mealType in Meal.MealType.allCases {
            calorieSums[mealType] = 0
            loggedCounts[mealType] = 0
        }

        for plan in plans {
            guard plan.meals.contains(where: { !$0.items.isEmpty }) else { continue }
            for meal in plan.meals {
                let cal = meal.items.reduce(0) { $0 + $1.calories }
                if cal > 0 {
                    calorieSums[meal.type, default: 0] += cal
                    loggedCounts[meal.type, default: 0] += 1
                }
            }
        }

        var result: [Meal.MealType: MealTypeAverage] = [:]
        for mealType in Meal.MealType.allCases {
            let count = loggedCounts[mealType] ?? 0
            let avg = count > 0 ? (calorieSums[mealType] ?? 0) / count : 0
            result[mealType] = MealTypeAverage(
                type: mealType,
                averageCalories: avg,
                loggedCount: count,
                totalDays: totalDays
            )
        }
        return result
    }

    // MARK: - Streak

    /// Count consecutive days ending today that have food logged.
    private func computeStreak(entries: [DailyCalorieEntry]) -> Int {
        var streak = 0
        for entry in entries.reversed() {
            if entry.hasFood {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Consistency

    /// Average closeness to target as a percentage (100 = exactly at target).
    private func computeConsistency(loggedEntries: [DailyCalorieEntry], target: Double) -> Int {
        guard !loggedEntries.isEmpty, target > 0 else { return 0 }
        let percents = loggedEntries.map { entry -> Double in
            let diff = abs(Double(entry.calories) - target)
            return max(0, 1.0 - Double(diff) / Double(target))
        }
        let avg = percents.reduce(0, +) / Double(percents.count)
        return Int(avg * 100)
    }

    // MARK: - Observations

    /// Generate 1-4 contextually relevant observations from the data.
    /// All strings use L10n keys for localization.
    private func generateObservations(
        loggedDays: Int,
        totalDays: Int,
        consistency: Int,
        streak: Int,
        mealTypeBreakdown: [Meal.MealType: MealTypeAverage]
    ) -> [InsightObservation] {
        guard loggedDays > 0 else {
            return [InsightObservation(
                icon: "fork.knife",
                title: L10n["insights.observation.empty_title"],
                detail: L10n["insights.observation.empty_detail"]
            )]
        }

        var observations: [InsightObservation] = []

        // 1. Consistency observation
        if consistency >= 85 {
            observations.append(InsightObservation(
                icon: "target",
                title: L10n["insights.observation.consistency_high_title", consistency],
                detail: L10n["insights.observation.consistency_high_detail"]
            ))
        } else if consistency < 60 {
            observations.append(InsightObservation(
                icon: "chart.line.downtrend.xyaxis",
                title: L10n["insights.observation.consistency_low_title", consistency],
                detail: L10n["insights.observation.consistency_low_detail"]
            ))
        } else {
            observations.append(InsightObservation(
                icon: "chart.line.flattrend.xyaxis",
                title: L10n["insights.observation.consistency_mid_title", consistency],
                detail: L10n["insights.observation.consistency_mid_detail"]
            ))
        }

        // 2. Streak observation (only for meaningful streaks)
        if streak >= 3 {
            observations.append(InsightObservation(
                icon: "flame.fill",
                title: L10n["insights.observation.streak_title", streak],
                detail: L10n["insights.observation.streak_detail"]
            ))
        }

        // 3. Heaviest meal observation (only if there's enough variety)
        let sortedMeals = mealTypeBreakdown.values
            .filter { $0.averageCalories > 0 }
            .sorted { $0.averageCalories > $1.averageCalories }
        if sortedMeals.count >= 2, let heaviest = sortedMeals.first {
            observations.append(InsightObservation(
                icon: heaviest.type.sfSymbol,
                title: L10n["insights.observation.heaviest_meal_title", heaviest.type.displayName],
                detail: L10n["insights.observation.heaviest_meal_detail", heaviest.averageCalories]
            ))
        }

        // 4. Logging frequency observation
        let loggingPercent = (loggedDays * 100) / totalDays
        if loggingPercent >= 70 {
            observations.append(InsightObservation(
                icon: "checkmark.seal.fill",
                title: L10n["insights.observation.frequency_high_title", loggedDays, totalDays],
                detail: L10n["insights.observation.frequency_high_detail"]
            ))
        } else if loggingPercent <= 30 {
            observations.append(InsightObservation(
                icon: "calendar.badge.clock",
                title: L10n["insights.observation.frequency_low_title", loggedDays, totalDays],
                detail: L10n["insights.observation.frequency_low_detail"]
            ))
        }

        return observations
    }

    // MARK: - Empty state

    private func emptySummary(days: Int, targetCalories: Double) -> InsightsSummary {
        InsightsSummary(
            dailyEntries: [],
            loggedDays: 0,
            totalDaysInRange: days,
            averageCalories: 0,
            averageRemaining: Int(targetCalories),
            targetCalories: targetCalories,
            macroBreakdown: MacroBreakdown(avgProtein: 0, avgCarbs: 0, avgFat: 0, totalGrams: 0),
            mealTypeBreakdown: [:],
            loggingStreak: 0,
            consistencyPercent: 0,
            observations: [InsightObservation(
                icon: "fork.knife",
                title: L10n["insights.observation.empty_title"],
                detail: L10n["insights.observation.empty_detail"]
            )],
            hasData: false
        )
    }
}
