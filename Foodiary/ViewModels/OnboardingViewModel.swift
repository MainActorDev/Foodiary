import SwiftUI

/// Owns all onboarding form state — single source of truth
/// replacing the 6 scattered `@State` properties in `ContentRootView`.
///
/// Provides computed `currentProfile` and `calculatedTarget` so
/// `CalorieResultView` doesn't need to construct a `UserProfile`
/// or call `CalorieCalculator` directly.
@Observable
final class OnboardingViewModel {
    var age = 30
    var sex: UserProfile.Sex = .female
    var heightCm: Double = 170
    var weightKg: Double = 70
    var activityLevel: UserProfile.ActivityLevel = .sedentary
    var goal: UserProfile.Goal = .maintain

    /// The `UserProfile` built from the current form state.
    /// Single construction site — no duplication across views.
    var currentProfile: UserProfile {
        UserProfile(
            age: age,
            sex: sex,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            goal: goal
        )
    }

    /// Calorie target for the current form state.
    /// No view needs to call `CalorieCalculator.calculate(for:)` directly.
    var calculatedTarget: CalorieTarget {
        CalorieCalculator.calculate(for: currentProfile)
    }

    /// BMI for the current form state.
    var bmi: Double {
        CalorieCalculator.bmi(weightKg: currentProfile.weightKg, heightCm: currentProfile.heightCm)
    }

    /// Recommended goal based on BMI category.
    var recommendedGoal: UserProfile.Goal {
        CalorieCalculator.bmiRecommendation(for: currentProfile)
    }
}
