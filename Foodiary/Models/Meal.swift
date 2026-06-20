import Foundation

struct Meal: Codable, Identifiable, Equatable {
    var id: UUID
    var mealPlanId: UUID?
    var type: MealType
    var items: [FoodItem]
    var createdAt: Date
    var updatedAt: Date
    
    var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }
    
    var itemCount: Int { items.count }
    
    enum MealType: String, Codable, CaseIterable {
        case breakfast, lunch, snack, dinner
        
        var displayName: String {
            rawValue.capitalized
        }
        
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
        mealPlanId: UUID? = nil,
        type: MealType,
        items: [FoodItem] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.mealPlanId = mealPlanId
        self.type = type
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
