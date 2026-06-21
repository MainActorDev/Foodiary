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
        
        var localizedDisplayName: String {
            switch self {
            case .breakfast: return L10n["model.meal.breakfast"]
            case .lunch: return L10n["model.meal.lunch"]
            case .snack: return L10n["model.meal.snack"]
            case .dinner: return L10n["model.meal.dinner"]
            }
        }
        
        var displayName: String { localizedDisplayName }
        
        var icon: String {
            switch self {
            case .breakfast: return "sunrise.fill"
            case .lunch: return "sun.max.fill"
            case .snack: return "cup.and.saucer.fill"
            case .dinner: return "moon.stars.fill"
            }
        }
        
        var colorName: String {
            switch self {
            case .breakfast: return "orange"
            case .lunch: return "mint"
            case .snack: return "pink"
            case .dinner: return "indigo"
            }
        }
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
