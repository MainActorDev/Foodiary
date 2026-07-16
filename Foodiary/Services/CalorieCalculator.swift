import Foundation

/// Stateless calorie calculator using Harris-Benedict equation.
/// All methods are pure functions — no side effects, fully testable.
enum CalorieCalculator {
    
    // MARK: - BMR (Harris-Benedict)
    
    /// Calculate Basal Metabolic Rate using Harris-Benedict equation
    static func bmr(for profile: UserProfile) -> Int {
        let w = profile.weightKg
        let h = profile.heightCm
        let a = Double(profile.age)
        
        let raw: Double
        switch profile.sex {
        case .male:
            // Harris-Benedict: 66.5 + (13.7 × weight) + (5 × height) – (6.8 × age)
            raw = 66.5 + (13.7 * w) + (5 * h) - (6.8 * a)
        case .female:
            // Harris-Benedict: 655 + (9.6 × weight) + (1.8 × height) – (4.7 × age)
            raw = 655 + (9.6 * w) + (1.8 * h) - (4.7 * a)
        }
        return Int(round(raw))
    }
    
    // MARK: - Maintenance & Target
    
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
    
    // MARK: - BMI
    
    /// Calculate Body Mass Index from weight (kg) and height (cm)
    static func bmi(weightKg: Double, heightCm: Double) -> Double {
        guard heightCm > 0 else { return 0 }
        let heightM = heightCm / 100.0
        return weightKg / (heightM * heightM)
    }
    
    /// WHO BMI category
    enum BMICategory: String, CaseIterable {
        case underweight, normal, overweight, obese
        
        /// The weight goal recommendation for this BMI category
        var recommendedGoal: UserProfile.Goal {
            switch self {
            case .underweight: return .gain
            case .normal: return .maintain
            case .overweight, .obese: return .lose
            }
        }
    }
    
    /// Classify a BMI value into a WHO category
    static func bmiCategory(_ bmi: Double) -> BMICategory {
        switch bmi {
        case ..<18.5: return .underweight
        case 18.5..<25: return .normal
        case 25..<30: return .overweight
        default: return .obese
        }
    }
    
    /// Get the recommended goal based on user's BMI
    static func bmiRecommendation(for profile: UserProfile) -> UserProfile.Goal {
        let value = bmi(weightKg: profile.weightKg, heightCm: profile.heightCm)
        return bmiCategory(value).recommendedGoal
    }
    
    // MARK: - Ideal Weight Range
    
    /// Calculate the ideal body weight range based on height and normal BMI (18.5–24.9).
    /// Returns (minKg, maxKg) rounded to 1 decimal place.
    static func idealWeightRange(heightCm: Double) -> (minKg: Double, maxKg: Double) {
        let heightM = heightCm / 100.0
        let minWeight = 18.5 * heightM * heightM
        let maxWeight = 24.9 * heightM * heightM
        return (
            minKg: (minWeight * 10).rounded() / 10,
            maxKg: (maxWeight * 10).rounded() / 10
        )
    }
}
