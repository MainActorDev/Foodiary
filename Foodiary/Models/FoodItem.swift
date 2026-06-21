import Foundation
import SwiftData

@Model
final class FoodItem {
    var id: UUID = UUID()
    var name: String = ""
    var calories: Int = 0
    var protein: Int = 0
    var carbs: Int = 0
    var fat: Int = 0
    var note: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    var meal: Meal?
    
    init(
        id: UUID = UUID(),
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
