import Foundation
import SwiftData

@Model
final class Meal {
    var id: UUID = UUID()
    var typeRaw: String = MealType.breakfast.rawValue
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    @Relationship(deleteRule: .cascade)
    var items: [FoodItem] = []
    
    var mealPlan: MealPlan?
    
    @Transient
    var type: MealType {
        get { MealType(rawValue: typeRaw) ?? .breakfast }
        set { typeRaw = newValue.rawValue }
    }
    
    @Transient
    var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }
    
    @Transient
    var itemCount: Int { items.count }
    
    enum MealType: String, Codable, CaseIterable {
        case breakfast, lunch, snack, dinner
    }
    
    init(
        id: UUID = UUID(),
        type: MealType = .breakfast,
        items: [FoodItem] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
