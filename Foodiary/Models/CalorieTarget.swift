import Foundation
import SwiftData

@Model
final class CalorieTarget {
    var id: UUID = UUID()
    var bmr: Int = 0
    var maintenanceCalories: Int = 0
    var targetCalories: Int = 0
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    var profile: UserProfile?
    
    init(
        id: UUID = UUID(),
        bmr: Int,
        maintenanceCalories: Int,
        targetCalories: Int,
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
