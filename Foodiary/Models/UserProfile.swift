import Foundation

struct UserProfile: Codable, Identifiable, Equatable {
    var id: UUID
    var age: Int
    var sex: Sex
    var heightCm: Double
    var weightKg: Double
    var activityLevel: ActivityLevel
    var goal: Goal
    var createdAt: Date
    var updatedAt: Date
    
    enum Sex: String, Codable, CaseIterable {
        case male, female
        
        var displayName: String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            }
        }
    }
    
    enum ActivityLevel: String, Codable, CaseIterable {
        case sedentary, lightlyActive, moderatelyActive, veryActive
        
        var displayName: String {
            switch self {
            case .sedentary: return "Sedentary"
            case .lightlyActive: return "Lightly Active"
            case .moderatelyActive: return "Moderately Active"
            case .veryActive: return "Very Active"
            }
        }
        
        var multiplier: Double {
            switch self {
            case .sedentary: return 1.2
            case .lightlyActive: return 1.375
            case .moderatelyActive: return 1.55
            case .veryActive: return 1.725
            }
        }
    }
    
    enum Goal: String, Codable, CaseIterable {
        case maintain, lose, gain
        
        var displayName: String {
            switch self {
            case .maintain: return "Maintain weight"
            case .lose: return "Lose weight slowly"
            case .gain: return "Gain weight slowly"
            }
        }
        
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
        self.sex = sex
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.activityLevel = activityLevel
        self.goal = goal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
