import Foundation

/// Aggregated insights computed from historical MealPlan data.
/// Produced by ``InsightsService``, consumed by ``InsightsView``.
struct InsightsSummary {
    let dailyEntries: [DailyCalorieEntry]
    let loggedDays: Int
    let totalDaysInRange: Int
    let averageCalories: Int
    let averageRemaining: Int
    let targetCalories: Double
    let macroBreakdown: MacroBreakdown
    let mealTypeBreakdown: [Meal.MealType: MealTypeAverage]
    let loggingStreak: Int
    let consistencyPercent: Int
    let observations: [InsightObservation]
    let hasData: Bool
}

/// One day's calorie data point in the chart.
struct DailyCalorieEntry {
    let date: Date
    let calories: Int
    let targetCalories: Double
    let isToday: Bool
    let hasFood: Bool

    var isOverTarget: Bool { Double(calories) > targetCalories && hasFood }
}

/// Aggregated macro averages across all logged days.
struct MacroBreakdown {
    let avgProtein: Int
    let avgCarbs: Int
    let avgFat: Int
    let totalGrams: Int

    var proteinPercent: Double {
        guard totalGrams > 0 else { return 0 }
        return Double(avgProtein) / Double(totalGrams)
    }
    var carbsPercent: Double {
        guard totalGrams > 0 else { return 0 }
        return Double(avgCarbs) / Double(totalGrams)
    }
    var fatPercent: Double {
        guard totalGrams > 0 else { return 0 }
        return Double(avgFat) / Double(totalGrams)
    }
}

/// Average calories for a meal type across logged days.
struct MealTypeAverage {
    let type: Meal.MealType
    let averageCalories: Int
    let loggedCount: Int
    let totalDays: Int
}

/// A derived insight observation card.
struct InsightObservation: Identifiable {
    let id = UUID()
    let icon: String       // SF Symbol name
    let title: String
    let detail: String
}
