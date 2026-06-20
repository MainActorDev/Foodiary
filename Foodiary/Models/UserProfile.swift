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
        
        /// Localized display name from the String Catalog.
        var localizedDisplayName: String {
            switch self {
            case .male: return L10n["model.sex.male"]
            case .female: return L10n["model.sex.female"]
            }
        }
        
        /// Display name for backward compatibility — delegates to localized version.
        var displayName: String { localizedDisplayName }
    }
    
    enum ActivityLevel: String, Codable, CaseIterable {
        case sedentary, lightlyActive, moderatelyActive, veryActive
        
        /// Localized display name from the String Catalog.
        var localizedDisplayName: String {
            switch self {
            case .sedentary: return L10n["model.activity.sedentary"]
            case .lightlyActive: return L10n["model.activity.lightly_active"]
            case .moderatelyActive: return L10n["model.activity.moderately_active"]
            case .veryActive: return L10n["model.activity.very_active"]
            }
        }
        
        /// Display name for backward compatibility — delegates to localized version.
        var displayName: String { localizedDisplayName }
        
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
        
        /// Localized display name from the String Catalog.
        var localizedDisplayName: String {
            switch self {
            case .maintain: return L10n["model.goal.maintain"]
            case .lose: return L10n["model.goal.lose"]
            case .gain: return L10n["model.goal.gain"]
            }
        }
        
        /// Display name for backward compatibility — delegates to localized version.
        var displayName: String { localizedDisplayName }
        
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
