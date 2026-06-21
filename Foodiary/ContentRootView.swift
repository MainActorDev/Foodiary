import SwiftUI
import SwiftData

struct ContentRootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var state: AppState?
    @State private var onboardingPath = NavigationPath()
    
    // Onboarding form state
    @State private var age = 30
    @State private var sex: UserProfile.Sex = .female
    @State private var heightCm: Double = 170
    @State private var weightKg: Double = 70
    @State private var activityLevel: UserProfile.ActivityLevel = .sedentary
    @State private var goal: UserProfile.Goal = .maintain
    
    var body: some View {
        Group {
            if let state = state {
                if state.isOnboarded {
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
                                    onBack: { onboardingPath.removeLast() },
                                    onContinue: { onboardingPath.append("goal-setup") }
                                )
                            case "goal-setup":
                                GoalSetupView(
                                    activityLevel: $activityLevel,
                                    goal: $goal,
                                    onBack: { onboardingPath.removeLast() },
                                    onCalculate: { onboardingPath.append("result") }
                                )
                            case "result":
                                CalorieResultView(
                                    target: CalorieCalculator.calculate(for: UserProfile(
                                        age: age, sex: sex,
                                        heightCm: heightCm, weightKg: weightKg,
                                        activityLevel: activityLevel, goal: goal
                                    )),
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
                            default:
                                EmptyView()
                            }
                        }
                    }
                    .tint(FoodiaryDesign.coral)
                }
            } else {
                VStack {
                    Text("🥗")
                        .font(.system(size: 64))
                    Text(L10n["app.name"])
                        .font(FoodiaryTypography.display)
                        .foregroundColor(FoodiaryDesign.black)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(FoodiaryDesign.background)
            }
        }
        .onAppear {
            state = AppState(modelContext: modelContext)
        }
    }
}
