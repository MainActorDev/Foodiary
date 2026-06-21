import Foundation

/// Stateless calorie calculator using Mifflin-St Jeor equation.
/// All methods are pure functions — no side effects, fully testable.
enum CalorieCalculator {
    
    /// Calculate Basal Metabolic Rate using Mifflin-St Jeor equation
    static func bmr(for profile: UserProfile) -> Int {
        let w = profile.weightKg
        let h = profile.heightCm
        let a = Double(profile.age)
        
        let raw: Double
        switch profile.sex {
        case .male:
            raw = 10 * w + 6.25 * h - 5 * a + 5
        case .female:
            raw = 10 * w + 6.25 * h - 5 * a - 161
        }
        return Int(round(raw))
    }
    
    /// Apply activity level multiplier to BMR
    static func maintenanceCalories(bmr: Int, activityLevel: UserProfile.ActivityLevel) -> Int {
        Int(round(Double(bmr) * activityLevel.multiplier))
    }
    
    /// Apply goal adjustment to maintenance calories
    static func targetCalories(maintenance: Int, goal: UserProfile.Goal) -> Int {
        let raw = Double(maintenance) * goal.multiplier
        // Round to nearest 10
        return Int(round(raw / 10) * 10)
    }
    
    /// Full calculation: profile → calorie target
    static func calculate(for profile: UserProfile) -> CalorieTarget {
        let b = bmr(for: profile)
        let m = maintenanceCalories(bmr: b, activityLevel: profile.activityLevel)
        let t = targetCalories(maintenance: m, goal: profile.goal)
        
        return CalorieTarget(
            bmr: b,
            maintenanceCalories: m,
            targetCalories: t
        )
    }
}
