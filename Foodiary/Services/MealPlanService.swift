import Foundation
import SwiftData

/// Manages meal plan CRUD operations — create, read, update food items,
/// batch week queries, and meal data checks.
///
/// Extracted from `AppState` to enforce single responsibility.
/// Depends on `PersistenceService` rather than concrete `ModelContext`.
@MainActor
final class MealPlanService {
    private let persistence: any PersistenceService

    init(persistence: any PersistenceService) {
        self.persistence = persistence
    }

    // MARK: - Fetch

    /// Fetch (or create) the meal plan for a specific day.
    func mealPlan(for date: Date) -> MealPlan? {
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
        return try? persistence.fetch(fetch).first
    }

    /// Create a new meal plan for a given day (no-op if one already exists).
    func createMealPlan(for date: Date, targetCalories: Int) {
        guard mealPlan(for: date) == nil else { return }
        let plan = MealPlan(date: date, targetCalories: targetCalories)
        persistence.insert(plan)
        do {
            try persistence.save()
        } catch {
            print("[MealPlanService] Failed to create meal plan: \(error)")
        }
    }

    // MARK: - Food Items

    /// Add a food item to a meal slot for a specific date.
    func addFoodItem(_ item: FoodItem, toMealAt index: Int, for date: Date) {
        guard let plan = mealPlan(for: date),
              index < plan.sortedMeals.count else { return }
        let foodItem = item
        let meal = plan.sortedMeals[index]
        foodItem.meal = meal
        meal.items.append(foodItem)
        plan.updatedAt = Date()
        persistence.insert(foodItem)
        do {
            try persistence.save()
        } catch {
            print("[MealPlanService] Failed to add food item: \(error)")
        }
    }

    /// Update an existing food item within a meal for a specific date.
    func updateFoodItem(_ item: FoodItem, mealIndex: Int, itemIndex: Int, for date: Date) {
        guard let plan = mealPlan(for: date),
              mealIndex < plan.sortedMeals.count,
              itemIndex < plan.sortedMeals[mealIndex].items.count else { return }
        plan.sortedMeals[mealIndex].items[itemIndex] = item
        plan.updatedAt = Date()
        do {
            try persistence.save()
        } catch {
            print("[MealPlanService] Failed to update food item: \(error)")
        }
    }

    /// Delete a food item from a meal for a specific date.
    func deleteFoodItem(mealIndex: Int, itemIndex: Int, for date: Date) {
        guard let plan = mealPlan(for: date),
              mealIndex < plan.sortedMeals.count,
              itemIndex < plan.sortedMeals[mealIndex].items.count else { return }
        let item = plan.sortedMeals[mealIndex].items[itemIndex]
        plan.sortedMeals[mealIndex].items.remove(at: itemIndex)
        persistence.delete(item)
        plan.updatedAt = Date()
        do {
            try persistence.save()
        } catch {
            print("[MealPlanService] Failed to delete food item: \(error)")
        }
    }

    // MARK: - Batch queries

    /// Check whether a given date has meal data.
    func hasMealData(for date: Date) -> (hasPlan: Bool, totalCal: Int) {
        guard let plan = mealPlan(for: date) else { return (false, 0) }
        let hasItems = plan.meals.contains { !$0.items.isEmpty }
        return (hasItems, plan.totalCalories)
    }

    /// Batch-check meal data for multiple dates.
    func mealDataForWeek(dates: [Date]) -> [(date: Date, hasData: Bool, totalCal: Int)] {
        dates.map { date in
            let (hasData, totalCal) = hasMealData(for: date)
            return (date, hasData, totalCal)
        }
    }
}
