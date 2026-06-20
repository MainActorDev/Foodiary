import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var calorieTarget: CalorieTarget?
    @Published var todayMealPlan: MealPlan?
    @Published var isLoading = true
    
    var isOnboarded: Bool {
        userProfile != nil && calorieTarget != nil
    }
    
    var hasTodayMealPlan: Bool {
        todayMealPlan != nil
    }
    
    // MARK: - Init
    
    init() {
        loadFromStorage()
    }
    
    private func loadFromStorage() {
        userProfile = StorageService.loadProfile()
        calorieTarget = StorageService.loadTarget()
        todayMealPlan = StorageService.loadMealPlan(for: Date())
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
    
    func recalculateTarget() {
        guard let profile = userProfile else { return }
        calculateAndSaveTarget(for: profile)
        // Update today's meal plan target if it exists
        if var plan = todayMealPlan, let target = calorieTarget {
            plan.targetCalories = target.targetCalories
            plan.updatedAt = Date()
            todayMealPlan = plan
            try? StorageService.saveMealPlan(plan)
        }
    }
    
    // MARK: - Meal Plan
    
    func createTodayMealPlan() {
        let target = calorieTarget?.targetCalories ?? 2000
        let plan = MealPlan(date: Date(), targetCalories: target)
        todayMealPlan = plan
        try? StorageService.saveMealPlan(plan)
    }
    
    func addFoodItem(_ item: FoodItem, toMealAt index: Int) {
        guard var plan = todayMealPlan, index < plan.meals.count else { return }
        var foodItem = item
        foodItem.mealId = plan.meals[index].id
        plan.meals[index].items.append(foodItem)
        plan.updatedAt = Date()
        todayMealPlan = plan
        try? StorageService.saveMealPlan(plan)
    }
    
    func updateFoodItem(_ item: FoodItem, mealIndex: Int, itemIndex: Int) {
        guard var plan = todayMealPlan,
              mealIndex < plan.meals.count,
              itemIndex < plan.meals[mealIndex].items.count else { return }
        var foodItem = item
        foodItem.updatedAt = Date()
        plan.meals[mealIndex].items[itemIndex] = foodItem
        plan.updatedAt = Date()
        todayMealPlan = plan
        try? StorageService.saveMealPlan(plan)
    }
    
    func deleteFoodItem(mealIndex: Int, itemIndex: Int) {
        guard var plan = todayMealPlan,
              mealIndex < plan.meals.count,
              itemIndex < plan.meals[mealIndex].items.count else { return }
        plan.meals[mealIndex].items.remove(at: itemIndex)
        plan.updatedAt = Date()
        todayMealPlan = plan
        try? StorageService.saveMealPlan(plan)
    }
    
    // MARK: - Reset
    
    func resetAll() {
        userProfile = nil
        calorieTarget = nil
        todayMealPlan = nil
        try? StorageService.resetAll()
    }
    
    // MARK: - Computed
    
    var plannedCalories: Int {
        todayMealPlan?.totalCalories ?? 0
    }
    
    var targetCalories: Int {
        calorieTarget?.targetCalories ?? 2000
    }
    
    var remainingCalories: Int {
        targetCalories - plannedCalories
    }
    
    var isOverTarget: Bool {
        remainingCalories < 0
    }
    
    var isExactlyAtTarget: Bool {
        remainingCalories == 0 && plannedCalories > 0
    }
    
    var isUnderTarget: Bool {
        remainingCalories > 0
    }
    
    var calorieProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(1.0, Double(plannedCalories) / Double(targetCalories))
    }
    
    var statusMessage: String {
        if plannedCalories == 0 {
            return "No food planned yet"
        } else if isExactlyAtTarget {
            return "You are exactly at your target."
        } else if isOverTarget {
            return "\(abs(remainingCalories)) kcal over your estimated target"
        } else {
            return "\(remainingCalories) kcal under target"
        }
    }
}
