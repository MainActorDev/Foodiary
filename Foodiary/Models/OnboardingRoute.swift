import Foundation

/// Type-safe onboarding navigation routes.
///
/// Replaces the fragile raw String-based routing in `ContentRootView`
/// ("profile-setup", "goal-setup", "result") with a typed enum.
enum OnboardingRoute: Hashable {
    case profileSetup
    case goalSetup
    case result
}
