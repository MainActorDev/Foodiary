import Foundation

// MARK: - Today ViewModel

/// The data and actions needed by `TodayDashboardView`.
/// AppState conforms — but this protocol enables testing
/// with mocks and documents the exact view contract.
@MainActor
protocol TodayViewModel: AnyObject {
    var hasTodayMealPlan: Bool { get }
    var todayMealPlan: MealPlan? { get }
    var plannedCalories: Int { get }
    var targetCalories: Double { get }
    var remainingCalories: Double { get }
    var calorieProgress: Double { get }
    var totalProtein: Int { get }
    var totalCarbs: Int { get }
    var totalFat: Int { get }
}

// MARK: - Plan ViewModel

@MainActor
protocol PlanViewModel: AnyObject {
    var selectedPlanDate: Date { get set }
    var planDateMealPlan: MealPlan? { get }
    var isPlanDateToday: Bool { get }
    var isPlanDatePast: Bool { get }
    var targetCalories: Double { get }
    var hasTodayMealPlan: Bool { get }
    var hasPlanDateMealPlan: Bool { get }

    func hasMealData(for date: Date) -> (hasPlan: Bool, totalCal: Int)
    func mealDataForWeek(dates: [Date]) -> [(date: Date, hasData: Bool, totalCal: Int)]
    func loadMealPlansForWeek(containing date: Date)
    func createMealPlan(for date: Date)
    func addFoodItem(_ item: FoodItem, toMealAt index: Int)
}

// MARK: - Profile ViewModel

@MainActor
protocol ProfileViewModel: AnyObject {
    var userProfile: UserProfile? { get }
    var calorieTarget: CalorieTarget? { get }

    func saveProfile(_ profile: UserProfile)
    func resetAll()
}

// MARK: - Insights ViewModel

@MainActor
protocol InsightsViewModel: AnyObject {
    var targetCalories: Double { get }
    func insightsSummary(forDays days: Int) -> InsightsSummary
}
