import Foundation

/// Domain-level errors surfaced to the UI layer.
///
/// Replaces silent `print()` logging with structured errors
/// that views can display to the user.
enum AppError: Error, LocalizedError {
    case persistenceFailed(Error)
    case profileNotFound
    case mealPlanNotFound
    case invalidFoodData(String)

    var errorDescription: String? {
        switch self {
        case .persistenceFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .profileNotFound:
            return "No profile found. Please complete onboarding."
        case .mealPlanNotFound:
            return "No meal plan found for this date."
        case .invalidFoodData(let detail):
            return "Invalid food data: \(detail)"
        }
    }
}
