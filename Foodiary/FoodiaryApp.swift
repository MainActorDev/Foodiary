import SwiftUI

@main
struct FoodiaryApp: App {
    @StateObject private var state = AppState()
    @State private var onboardingPath = NavigationPath()
    
    // Onboarding form state
    @State private var age = 30
    @State private var sex: UserProfile.Sex = .female
    @State private var heightCm: Double = 170
    @State private var weightKg: Double = 70
    @State private var activityLevel: UserProfile.ActivityLevel = .sedentary
    @State private var goal: UserProfile.Goal = .maintain
    @State private var calculatedTarget: CalorieTarget?
    
    init() {
        // Global nav bar styling
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(FoodiaryDesign.background)
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor(FoodiaryDesign.black)
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor: UIColor(FoodiaryDesign.black)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(FoodiaryDesign.black)
        
        // Tab bar styling
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(FoodiaryDesign.white)
        tabAppearance.shadowColor = UIColor(FoodiaryDesign.black)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if state.isLoading {
                    VStack {
                        Text("🥗")
                            .font(.system(size: 64))
                        Text("Foodiary")
                            .font(FoodiaryTypography.display)
                            .foregroundColor(FoodiaryDesign.black)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(FoodiaryDesign.background)
                } else if state.isOnboarded {
                    MainTabView(state: state)
                } else {
                    NavigationStack(path: $onboardingPath) {
                        WelcomeView {
                            onboardingPath.append("profile-setup")
                        }
                        .navigationDestination(for: String.self) { destination in
                            switch destination {
                            case "profile-setup":
                                ProfileSetupView(
                                    age: $age,
                                    sex: $sex,
                                    heightCm: $heightCm,
                                    weightKg: $weightKg,
                                    onContinue: { onboardingPath.append("goal-setup") }
                                )
                            case "goal-setup":
                                GoalSetupView(
                                    activityLevel: $activityLevel,
                                    goal: $goal,
                                    onBack: { onboardingPath.removeLast() },
                                    onCalculate: {
                                        let profile = UserProfile(
                                            age: age, sex: sex,
                                            heightCm: heightCm, weightKg: weightKg,
                                            activityLevel: activityLevel, goal: goal
                                        )
                                        let target = CalorieCalculator.calculate(for: profile)
                                        calculatedTarget = target
                                        onboardingPath.append("result")
                                    }
                                )
                            case "result":
                                if let target = calculatedTarget {
                                    CalorieResultView(
                                        target: target,
                                        onBack: { onboardingPath.removeLast() },
                                        onCreateMealPlan: {
                                            let profile = UserProfile(
                                                age: age, sex: sex,
                                                heightCm: heightCm, weightKg: weightKg,
                                                activityLevel: activityLevel, goal: goal
                                            )
                                            state.saveProfile(profile)
                                            state.calculateAndSaveTarget(for: profile)
                                            state.createTodayMealPlan()
                                        },
                                        onEditProfile: { onboardingPath.removeLast(2) }
                                    )
                                }
                            default:
                                EmptyView()
                            }
                        }
                    }
                    .tint(FoodiaryDesign.coral)
                }
            }
        }
    }
}
