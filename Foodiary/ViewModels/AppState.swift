import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var calorieTarget: CalorieTarget?
    @Published var isLoading = true
    
    // Multi-date meal plan storage: keyed by "yyyy-MM-dd"
    @Published private(set) var _mealPlans: [String: MealPlan] = [:]
    
    /// The date currently selected in the Plan tab
    @Published var selectedPlanDate: Date = Date()
    
    var isOnboarded: Bool {
        userProfile != nil && calorieTarget != nil
    }
    
    /// Today's meal plan (computed from multi-date storage)
    var todayMealPlan: MealPlan? {
        _mealPlans[MealPlan.dateKey(for: Date())]
    }
    
    var hasTodayMealPlan: Bool {
        todayMealPlan != nil
    }
    
    /// The meal plan for the Plan tab's selected date
    var planDateMealPlan: MealPlan? {
        _mealPlans[MealPlan.dateKey(for: selectedPlanDate)]
    }
    
    var hasPlanDateMealPlan: Bool {
        planDateMealPlan != nil
    }
    
    /// Whether the Plan tab's selected date is today
    var isPlanDateToday: Bool {
        Calendar.current.isDateInToday(selectedPlanDate)
    }
    
    /// Whether the Plan tab's selected date is in the past
    var isPlanDatePast: Bool {
        selectedPlanDate < Calendar.current.startOfDay(for: Date())
    }
    
    // MARK: - Init
    
    init() {
        loadFromStorage()
    }
    
    private func loadFromStorage() {
        userProfile = StorageService.loadProfile()
        calorieTarget = StorageService.loadTarget()
        // Load today's meal plan into the dictionary
        if let todayPlan = StorageService.loadMealPlan(for: Date()) {
            _mealPlans[MealPlan.dateKey(for: Date())] = todayPlan
        }
        isLoading = false
    }
    
    // MARK: - Profile
    
    func saveProfile(_ profile: UserProfile) {
        var p = profile
        p.updatedAt = Date()
        userProfile = p
        do {
            try StorageService.saveProfile(p)
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
    
    // MARK: - Calorie Target
    
    func calculateAndSaveTarget(for profile: UserProfile) {
        let target = CalorieCalculator.calculate(for: profile)
        calorieTarget = target
        do {
            try StorageService.saveTarget(target)
        } catch {
            print("Failed to save target: \(error)")
        }
    }
    
    // MARK: - Meal Plan (date-aware)
    
    /// Load a meal plan for a specific date from disk
    func loadMealPlan(for date: Date) {
        let key = MealPlan.dateKey(for: date)
        guard _mealPlans[key] == nil else { return }
        if let plan = StorageService.loadMealPlan(for: date) {
            _mealPlans[key] = plan
        }
    }
    
    /// Create a new empty meal plan for a specific date
    func createMealPlan(for date: Date) {
        let key = MealPlan.dateKey(for: date)
        let target = calorieTarget?.targetCalories ?? 2000
        let plan = MealPlan(date: date, targetCalories: target)
        _mealPlans[key] = plan
        try? StorageService.saveMealPlan(plan)
    }
    
    /// Create today's meal plan (convenience)
    func createTodayMealPlan() {
        createMealPlan(for: Date())
    }
    
    /// Add a food item to a meal in a specific date's plan
    func addFoodItem(_ item: FoodItem, toMealAt index: Int, for date: Date) {
        let key = MealPlan.dateKey(for: date)
        guard var plan = _mealPlans[key], index < plan.meals.count else { return }
        var foodItem = item
        foodItem.mealId = plan.meals[index].id
        plan.meals[index].items.append(foodItem)
        plan.updatedAt = Date()
        _mealPlans[key] = plan
        try? StorageService.saveMealPlan(plan)
    }
    
    /// Convenience: add to today's plan
    func addFoodItem(_ item: FoodItem, toMealAt index: Int) {
        addFoodItem(item, toMealAt: index, for: Date())
    }
    
    /// Update a food item in a specific date's plan
    func updateFoodItem(_ item: FoodItem, mealIndex: Int, itemIndex: Int, for date: Date) {
        let key = MealPlan.dateKey(for: date)
        guard var plan = _mealPlans[key],
              mealIndex < plan.meals.count,
              itemIndex < plan.meals[mealIndex].items.count else { return }
        var foodItem = item
        foodItem.updatedAt = Date()
        plan.meals[mealIndex].items[itemIndex] = foodItem
        plan.updatedAt = Date()
        _mealPlans[key] = plan
        try? StorageService.saveMealPlan(plan)
    }
    
    /// Convenience: update in today's plan
    func updateFoodItem(_ item: FoodItem, mealIndex: Int, itemIndex: Int) {
        updateFoodItem(item, mealIndex: mealIndex, itemIndex: itemIndex, for: Date())
    }
    
    /// Delete a food item from a specific date's plan
    func deleteFoodItem(mealIndex: Int, itemIndex: Int, for date: Date) {
        let key = MealPlan.dateKey(for: date)
        guard var plan = _mealPlans[key],
              mealIndex < plan.meals.count,
              itemIndex < plan.meals[mealIndex].items.count else { return }
        plan.meals[mealIndex].items.remove(at: itemIndex)
        plan.updatedAt = Date()
        _mealPlans[key] = plan
        try? StorageService.saveMealPlan(plan)
    }
    
    /// Convenience: delete from today's plan
    func deleteFoodItem(mealIndex: Int, itemIndex: Int) {
        deleteFoodItem(mealIndex: mealIndex, itemIndex: itemIndex, for: Date())
    }
    
    /// Pre-load a week's worth of meal plans (for Plan view week strip dots)
    func loadMealPlansForWeek(containing date: Date) {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            loadMealPlan(for: day)
        }
    }
    
    // MARK: - Reset
    
    func resetAll() {
        userProfile = nil
        calorieTarget = nil
        _mealPlans = [:]
        try? StorageService.resetAll()
    }
    
    // MARK: - Computed: Calories (uses today's plan for Today tab)
    
    var plannedCalories: Int {
        todayMealPlan?.totalCalories ?? 0
    }
    
    var targetCalories: Int {
        calorieTarget?.targetCalories ?? 2000
    }
    
    var remainingCalories: Int {
        targetCalories - plannedCalories
    }
    
    var isOverTarget: Bool { remainingCalories < 0 }
    var isExactlyAtTarget: Bool { remainingCalories == 0 && plannedCalories > 0 }
    var isUnderTarget: Bool { remainingCalories > 0 }
    
    var calorieProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(1.0, Double(plannedCalories) / Double(targetCalories))
    }
    
    // MARK: - Computed: Macros
    
    var totalProtein: Int {
        todayMealPlan?.meals.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.protein } } ?? 0
    }
    
    var totalCarbs: Int {
        todayMealPlan?.meals.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.carbs } } ?? 0
    }
    
    var totalFat: Int {
        todayMealPlan?.meals.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.fat } } ?? 0
    }
    
    var maxMacro: Int {
        max(max(totalProtein, totalCarbs), max(totalFat, 1))
    }
    
    /// User-facing status message
    var localizedStatusMessage: String {
        if plannedCalories == 0 {
            return L10n["status.no_food"]
        } else if isExactlyAtTarget {
            return L10n["status.exact_target"]
        } else if isOverTarget {
            return L10n["status.over_target", abs(remainingCalories)]
        } else {
            return L10n["status.under_target", remainingCalories]
        }
    }
    
    var statusMessage: String { localizedStatusMessage }
    
    // MARK: - Plan-specific computed properties
    
    /// Calories planned for the Plan tab's selected date
    var planDateCalories: Int {
        planDateMealPlan?.totalCalories ?? 0
    }
    
    /// Remaining calories for the Plan tab's selected date
    var planDateRemaining: Int {
        targetCalories - planDateCalories
    }
    
    /// Progress for the Plan tab's selected date
    var planDateProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(1.0, Double(planDateCalories) / Double(targetCalories))
    }
    
    var isPlanDateOver: Bool { planDateRemaining < 0 }
    
    /// Status message for the Plan tab's selected date
    var planDateStatusMessage: String {
        if planDateCalories == 0 {
            return L10n["status.no_food"]
        } else if planDateRemaining == 0 && planDateCalories > 0 {
            return L10n["status.exact_target"]
        } else if isPlanDateOver {
            return L10n["status.over_target", abs(planDateRemaining)]
        } else {
            return L10n["status.under_target", planDateRemaining]
        }
    }
}
