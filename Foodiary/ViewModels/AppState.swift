import SwiftUI
import SwiftData

/// Central coordinator — owns domain services and exposes
/// computed properties for the UI layer.
///
/// Delegates all persistence to `ProfileService` and `MealPlanService`,
/// which depend on `PersistenceService` (not concrete `ModelContext`).
@MainActor
@Observable
final class AppState: TodayViewModel, PlanViewModel, ProfileViewModel, InsightsViewModel {
    private let profileService: ProfileService
    private let mealPlanService: MealPlanService
    private let insightsService: InsightsService

    var selectedPlanDate: Date = Date()
    var errorMessage: String?

    // Cached values to avoid repeated DB fetches in computed property chains
    private var _cachedProfile: UserProfile?
    private var _cachedTodayPlan: MealPlan?
    private var _cacheValidProfile = false
    private var _cacheValidToday = false

    init(persistence: any PersistenceService) {
        self.profileService = ProfileService(persistence: persistence)
        self.mealPlanService = MealPlanService(persistence: persistence)
        self.insightsService = InsightsService(persistence: persistence)
    }

    // MARK: - Profile

    var userProfile: UserProfile? {
        if _cacheValidProfile { return _cachedProfile }
        _cachedProfile = profileService.fetchProfile()
        _cacheValidProfile = true
        return _cachedProfile
    }

    var calorieTarget: CalorieTarget? {
        userProfile?.calorieTarget
    }

    var isOnboarded: Bool {
        userProfile != nil && calorieTarget != nil
    }

    func saveProfile(_ profile: UserProfile) {
        profileService.saveProfile(profile)
        invalidateCache()
    }

    // MARK: - Calorie Target

    func calculateAndSaveTarget(for profile: UserProfile) {
        profileService.calculateAndSaveTarget(for: profile)
    }

    // MARK: - Meal Plan (date-aware)

    var todayMealPlan: MealPlan? {
        if _cacheValidToday { return _cachedTodayPlan }
        _cachedTodayPlan = mealPlanService.mealPlan(for: Date())
        _cacheValidToday = true
        return _cachedTodayPlan
    }

    var hasTodayMealPlan: Bool { todayMealPlan != nil }

    var planDateMealPlan: MealPlan? {
        mealPlanService.mealPlan(for: selectedPlanDate)
    }

    var hasPlanDateMealPlan: Bool { planDateMealPlan != nil }

    var isPlanDateToday: Bool {
        Calendar.current.isDateInToday(selectedPlanDate)
    }

    var isPlanDatePast: Bool {
        // Past = before the start of the current week (this Monday).
        // Days in the current week stay editable even if they've already passed;
        // only previous weeks are read-only.
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let mondayOffset = weekday == 1 ? -6 : 2 - weekday
        let thisMonday = calendar.date(byAdding: .day, value: mondayOffset, to: Date()) ?? Date()
        return selectedPlanDate < thisMonday
    }

    func mealPlanForDate(_ date: Date) -> MealPlan? {
        mealPlanService.mealPlan(for: date)
    }

    func createMealPlan(for date: Date) {
        let target = calorieTarget?.targetCalories ?? 2000
        mealPlanService.createMealPlan(for: date, targetCalories: target)
        invalidateCache()
    }

    func createTodayMealPlan() {
        createMealPlan(for: Date())
    }

    func addFoodItem(_ item: FoodItem, toMealAt index: Int, for date: Date) {
        mealPlanService.addFoodItem(item, toMealAt: index, for: date)
        invalidateCache()
    }

    func addFoodItem(_ item: FoodItem, toMealAt index: Int) {
        addFoodItem(item, toMealAt: index, for: Date())
    }

    func updateFoodItem(_ item: FoodItem, mealIndex: Int, itemIndex: Int, for date: Date) {
        mealPlanService.updateFoodItem(item, mealIndex: mealIndex, itemIndex: itemIndex, for: date)
    }

    func updateFoodItem(_ item: FoodItem, mealIndex: Int, itemIndex: Int) {
        updateFoodItem(item, mealIndex: mealIndex, itemIndex: itemIndex, for: Date())
    }

    func deleteFoodItem(mealIndex: Int, itemIndex: Int, for date: Date) {
        mealPlanService.deleteFoodItem(mealIndex: mealIndex, itemIndex: itemIndex, for: date)
        invalidateCache()
    }

    func deleteFoodItem(mealIndex: Int, itemIndex: Int) {
        deleteFoodItem(mealIndex: mealIndex, itemIndex: itemIndex, for: Date())
    }

    func loadMealPlansForWeek(containing date: Date) {
        // SwiftData fetches on demand — explicit pre-load not needed
    }

    // MARK: - Plan helpers

    func hasMealData(for date: Date) -> (hasPlan: Bool, totalCal: Int) {
        mealPlanService.hasMealData(for: date)
    }

    func mealDataForWeek(dates: [Date]) -> [(date: Date, hasData: Bool, totalCal: Int)] {
        mealPlanService.mealDataForWeek(dates: dates)
    }

    // MARK: - Insights

    func insightsSummary(forDays days: Int) -> InsightsSummary {
        insightsService.summary(forDays: days, targetCalories: targetCalories)
    }

    // MARK: - Reset

    func resetAll() {
        profileService.deleteAllData()
        invalidateCache()
    }

    // MARK: - Cache invalidation

    private func invalidateCache() {
        _cacheValidProfile = false
        _cacheValidToday = false
    }

    // MARK: - Computed: Today

    var plannedCalories: Int { todayMealPlan?.totalCalories ?? 0 }
    var targetCalories: Int { calorieTarget?.targetCalories ?? 2000 }
    var remainingCalories: Int { targetCalories - plannedCalories }
    var isOverTarget: Bool { remainingCalories < 0 }
    var isExactlyAtTarget: Bool { remainingCalories == 0 && plannedCalories > 0 }
    var isUnderTarget: Bool { remainingCalories > 0 }
    var calorieProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(1.0, Double(plannedCalories) / Double(targetCalories))
    }

    var totalProtein: Int { todayMealPlan?.meals.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.protein } } ?? 0 }
    var totalCarbs: Int { todayMealPlan?.meals.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.carbs } } ?? 0 }
    var totalFat: Int { todayMealPlan?.meals.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.fat } } ?? 0 }
    var maxMacro: Int { max(max(totalProtein, totalCarbs), max(totalFat, 1)) }

    var localizedStatusMessage: String {
        if plannedCalories == 0 { return L10n["status.no_food"] }
        else if isExactlyAtTarget { return L10n["status.exact_target"] }
        else if isOverTarget { return L10n["status.over_target", abs(remainingCalories)] }
        else { return L10n["status.under_target", remainingCalories] }
    }
    var statusMessage: String { localizedStatusMessage }

    // MARK: - Computed: Plan

    var planDateCalories: Int { planDateMealPlan?.totalCalories ?? 0 }
    var planDateRemaining: Int { targetCalories - planDateCalories }
    var planDateProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(1.0, Double(planDateCalories) / Double(targetCalories))
    }
    var isPlanDateOver: Bool { planDateRemaining < 0 }
    var planDateStatusMessage: String {
        if planDateCalories == 0 { return L10n["status.no_food"] }
        else if planDateRemaining == 0 && planDateCalories > 0 { return L10n["status.exact_target"] }
        else if isPlanDateOver { return L10n["status.over_target", abs(planDateRemaining)] }
        else { return L10n["status.under_target", planDateRemaining] }
    }
}
