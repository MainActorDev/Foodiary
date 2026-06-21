import SwiftUI
import SwiftData

@Observable
final class AppState {
    private var modelContext: ModelContext
    
    var selectedPlanDate: Date = Date()
    
    // Cached values to avoid repeated DB fetches in computed property chains
    private var _cachedProfile: UserProfile?
    private var _cachedTodayPlan: MealPlan?
    private var _cacheValidProfile = false
    private var _cacheValidToday = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Profile
    
    var userProfile: UserProfile? {
        if _cacheValidProfile { return _cachedProfile }
        var fetch = FetchDescriptor<UserProfile>()
        fetch.fetchLimit = 1
        _cachedProfile = try? modelContext.fetch(fetch).first
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
        // Delete existing profile if found
        if let existing = userProfile {
            modelContext.delete(existing)
        }
        var p = profile
        p.updatedAt = Date()
        modelContext.insert(p)
        do {
            try modelContext.save()
            invalidateCache()
        } catch {
            print("[AppState] Failed to save profile: \(error)")
        }
    }
    
    // MARK: - Calorie Target
    
    func calculateAndSaveTarget(for profile: UserProfile) {
        let target = CalorieCalculator.calculate(for: profile)
        target.profile = profile
        profile.calorieTarget = target
        modelContext.insert(target)
        do {
            try modelContext.save()
        } catch {
            print("[AppState] Failed to save calorie target: \(error)")
        }
    }
    
    // MARK: - Meal Plan (date-aware)
    
    var todayMealPlan: MealPlan? {
        if _cacheValidToday { return _cachedTodayPlan }
        _cachedTodayPlan = mealPlan(for: Date())
        _cacheValidToday = true
        return _cachedTodayPlan
    }
    
    var hasTodayMealPlan: Bool { todayMealPlan != nil }
    
    var planDateMealPlan: MealPlan? {
        mealPlan(for: selectedPlanDate)
    }
    
    var hasPlanDateMealPlan: Bool { planDateMealPlan != nil }
    
    var isPlanDateToday: Bool {
        Calendar.current.isDateInToday(selectedPlanDate)
    }
    
    var isPlanDatePast: Bool {
        selectedPlanDate < Calendar.current.startOfDay(for: Date())
    }
    
    func mealPlanForDate(_ date: Date) -> MealPlan? {
        mealPlan(for: date)
    }
    
    private func mealPlan(for date: Date) -> MealPlan? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            return nil
        }
        var fetch = FetchDescriptor<MealPlan>(
            predicate: #Predicate { plan in
                plan.date >= startOfDay && plan.date < endOfDay
            }
        )
        fetch.fetchLimit = 1
        return try? modelContext.fetch(fetch).first
    }
    
    func createMealPlan(for date: Date) {
        guard mealPlan(for: date) == nil else { return }
        let target = calorieTarget?.targetCalories ?? 2000
        let plan = MealPlan(date: date, targetCalories: target)
        modelContext.insert(plan)
        do {
            try modelContext.save()
            invalidateCache()
        } catch {
            print("[AppState] Failed to create meal plan: \(error)")
        }
    }
    
    func createTodayMealPlan() {
        createMealPlan(for: Date())
    }
    
    func addFoodItem(_ item: FoodItem, toMealAt index: Int, for date: Date) {
        guard let plan = mealPlan(for: date),
              index < plan.meals.count else { return }
        var foodItem = item
        foodItem.meal = plan.meals[index]
        plan.meals[index].items.append(foodItem)
        plan.updatedAt = Date()
        modelContext.insert(foodItem)
        do {
            try modelContext.save()
            invalidateCache()
        } catch {
            print("[AppState] Failed to add food item: \(error)")
        }
    }
    
    func addFoodItem(_ item: FoodItem, toMealAt index: Int) {
        addFoodItem(item, toMealAt: index, for: Date())
    }
    
    func updateFoodItem(_ item: FoodItem, mealIndex: Int, itemIndex: Int, for date: Date) {
        guard let plan = mealPlan(for: date),
              mealIndex < plan.meals.count,
              itemIndex < plan.meals[mealIndex].items.count else { return }
        plan.meals[mealIndex].items[itemIndex] = item
        plan.updatedAt = Date()
        do {
            try modelContext.save()
        } catch {
            print("[AppState] Failed to update food item: \(error)")
        }
    }
    
    func updateFoodItem(_ item: FoodItem, mealIndex: Int, itemIndex: Int) {
        updateFoodItem(item, mealIndex: mealIndex, itemIndex: itemIndex, for: Date())
    }
    
    func deleteFoodItem(mealIndex: Int, itemIndex: Int, for date: Date) {
        guard let plan = mealPlan(for: date),
              mealIndex < plan.meals.count,
              itemIndex < plan.meals[mealIndex].items.count else { return }
        let item = plan.meals[mealIndex].items[itemIndex]
        plan.meals[mealIndex].items.remove(at: itemIndex)
        modelContext.delete(item)
        plan.updatedAt = Date()
        do {
            try modelContext.save()
            invalidateCache()
        } catch {
            print("[AppState] Failed to delete food item: \(error)")
        }
    }
    
    func deleteFoodItem(mealIndex: Int, itemIndex: Int) {
        deleteFoodItem(mealIndex: mealIndex, itemIndex: itemIndex, for: Date())
    }
    
    func loadMealPlansForWeek(containing date: Date) {
        // SwiftData fetches on demand — explicit pre-load not needed
    }
    
    // MARK: - Plan helpers
    
    func hasMealData(for date: Date) -> (hasPlan: Bool, totalCal: Int) {
        guard let plan = mealPlan(for: date) else { return (false, 0) }
        let hasItems = plan.meals.contains { !$0.items.isEmpty }
        return (hasItems, plan.totalCalories)
    }
    
    /// Batch-check meal data for multiple dates (single fetch per date pattern)
    func mealDataForWeek(dates: [Date]) -> [(date: Date, hasData: Bool, totalCal: Int)] {
        dates.map { date in
            let (hasData, totalCal) = hasMealData(for: date)
            return (date, hasData, totalCal)
        }
    }
    
    // MARK: - Reset
    
    func resetAll() {
        if let profiles = try? modelContext.fetch(FetchDescriptor<UserProfile>()) {
            for profile in profiles { modelContext.delete(profile) }
        }
        do {
            try modelContext.save()
            invalidateCache()
        } catch {
            print("[AppState] Failed to reset all data: \(error)")
        }
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
