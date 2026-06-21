import Foundation

struct FoodItem: Codable, Identifiable, Equatable {
    var id: UUID
    var mealId: UUID?
    var name: String
    var calories: Int
    var protein: Int      // grams
    var carbs: Int        // grams
    var fat: Int          // grams
    var note: String
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        mealId: UUID? = nil,
        name: String = "",
        calories: Int = 0,
        protein: Int = 0,
        carbs: Int = 0,
        fat: Int = 0,
        note: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.mealId = mealId
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
