import Foundation
import SwiftData

@Model
final class CalorieTarget {
    var id: UUID = UUID()
    var bmr: Double = 0
    var maintenanceCalories: Double = 0
    var targetCalories: Double = 0
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    var profile: UserProfile?
    
    init(
        id: UUID = UUID(),
        bmr: Double,
        maintenanceCalories: Double,
        targetCalories: Double,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.bmr = bmr
        self.maintenanceCalories = maintenanceCalories
        self.targetCalories = targetCalories
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
