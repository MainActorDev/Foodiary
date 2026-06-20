import Foundation

struct MealPlan: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var targetCalories: Int
    var meals: [Meal]
    var createdAt: Date
    var updatedAt: Date
    
    var totalCalories: Int {
        meals.reduce(0) { $0 + $1.totalCalories }
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
