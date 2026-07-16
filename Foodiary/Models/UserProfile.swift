import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID = UUID()
    var age: Int = 30
    var sexRaw: String = Sex.female.rawValue
    var heightCm: Double = 170
    var weightKg: Double = 70
    var activityLevelRaw: String = ActivityLevel.sedentary.rawValue
    var goalRaw: String = Goal.maintain.rawValue
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    @Relationship(deleteRule: .cascade)
    var calorieTarget: CalorieTarget?
    
    @Transient var sex: Sex {
        get { Sex(rawValue: sexRaw) ?? .female }
        set { sexRaw = newValue.rawValue }
    }
    @Transient var activityLevel: ActivityLevel {
        get { ActivityLevel(rawValue: activityLevelRaw) ?? .sedentary }
        set { activityLevelRaw = newValue.rawValue }
    }
    @Transient var goal: Goal {
        get { Goal(rawValue: goalRaw) ?? .maintain }
        set { goalRaw = newValue.rawValue }
    }
    
    enum Sex: String, Codable, CaseIterable {
        case male, female
    }
    
    enum ActivityLevel: String, Codable, CaseIterable {
        case sedentary, lightlyActive, active
        var multiplier: Double {
            switch self {
            case .sedentary: return 1.2
            case .lightlyActive: return 1.3
            case .active: return 1.7
            }
        }
    }
    
    enum Goal: String, Codable, CaseIterable {
        case maintain, lose, gain
        var multiplier: Double {
            switch self {
            case .maintain: return 1.0
            case .lose: return 0.90
            case .gain: return 1.10
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        age: Int = 30,
        sex: Sex = .female,
        heightCm: Double = 170,
        weightKg: Double = 70,
        activityLevel: ActivityLevel = .sedentary,
        goal: Goal = .maintain,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.age = age
        self.sexRaw = sex.rawValue
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.activityLevelRaw = activityLevel.rawValue
        self.goalRaw = goal.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
