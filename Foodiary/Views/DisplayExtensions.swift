import SwiftUI

// MARK: - UserProfile display extensions
//
// Moved from Models/ to Views/ — models should be pure data,
// not depend on L10n or other UI frameworks.

extension UserProfile.Sex {
    var displayName: String {
        switch self {
        case .male: return L10n["model.sex.male"]
        case .female: return L10n["model.sex.female"]
        }
    }
}

extension UserProfile.ActivityLevel {
    var displayName: String {
        switch self {
        case .sedentary: return L10n["model.activity.sedentary"]
        case .lightlyActive: return L10n["model.activity.lightly_active"]
        case .active: return L10n["model.activity.active"]
        }
    }
}

extension UserProfile.Goal {
    var displayName: String {
        switch self {
        case .maintain: return L10n["model.goal.maintain"]
        case .lose: return L10n["model.goal.lose"]
        case .gain: return L10n["model.goal.gain"]
        }
    }
}

// MARK: - Meal.MealType display extensions

extension Meal.MealType {
    var displayName: String {
        switch self {
        case .breakfast: return L10n["model.meal.breakfast"]
        case .lunch: return L10n["model.meal.lunch"]
        case .snack: return L10n["model.meal.snack"]
        case .dinner: return L10n["model.meal.dinner"]
        }
    }

    /// Emoji for the meal type — single source of truth.
    var emoji: String {
        switch self {
        case .breakfast: return "🍳"
        case .lunch: return "🍱"
        case .snack: return "🍌"
        case .dinner: return "🍽️"
        }
    }

    /// SF Symbol for the meal type — used in observation cards.
    var sfSymbol: String {
        switch self {
        case .breakfast: return "sun.haze.fill"
        case .lunch: return "sun.max.fill"
        case .snack: return "leaf.fill"
        case .dinner: return "moon.stars.fill"
        }
    }
}
