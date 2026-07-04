import Foundation
import SwiftData

@Model
final class MealPlan {
    var id: UUID = UUID()
    var date: Date = Date()
    var targetCalories: Int = 2000
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    @Relationship(deleteRule: .cascade)
    var meals: [Meal] = []
    
    @Transient
    var totalCalories: Int {
        meals.reduce(0) { $0 + $1.totalCalories }
    }

    /// Meals sorted by canonical MealType order (breakfast → lunch → snack → dinner).
    /// SwiftData @Relationship arrays have no guaranteed order after fetch.
    @Transient
    var sortedMeals: [Meal] {
        let order = Meal.MealType.allCases.map(\.rawValue)
        return meals.sorted { order.firstIndex(of: $0.typeRaw) ?? 99 < order.firstIndex(of: $1.typeRaw) ?? 99 }
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        targetCalories: Int = 2000,
        meals: [Meal] = MealPlan.defaultMeals(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.targetCalories = targetCalories
        self.meals = meals
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    static func defaultMeals() -> [Meal] {
        Meal.MealType.allCases.map { Meal(type: $0) }
    }
    
    static func dateKey(for date: Date) -> String {
        DateFormatter.dateKey.string(from: date)
    }
}
