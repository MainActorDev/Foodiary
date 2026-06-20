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
        
        /// Localized display name from the String Catalog.
        var localizedDisplayName: String {
            switch self {
            case .breakfast: return L10n["model.meal.breakfast"]
            case .lunch: return L10n["model.meal.lunch"]
            case .snack: return L10n["model.meal.snack"]
            case .dinner: return L10n["model.meal.dinner"]
            }
        }
        
        /// Display name for backward compatibility — delegates to localized version.
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
