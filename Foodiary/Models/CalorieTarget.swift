import Foundation

struct CalorieTarget: Codable, Identifiable, Equatable {
    var id: UUID
    var profileId: UUID
    var bmr: Int
    var maintenanceCalories: Int
    var targetCalories: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        profileId: UUID,
        bmr: Int,
        maintenanceCalories: Int,
        targetCalories: Int,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.profileId = profileId
        self.bmr = bmr
        self.maintenanceCalories = maintenanceCalories
        self.targetCalories = targetCalories
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
