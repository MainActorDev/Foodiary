import SwiftUI
import SwiftData

struct ContentRootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var state: AppState?
    @State private var onboardingPath = NavigationPath()
    @State private var onboardingVM = OnboardingViewModel()
    @State private var profileSetupID = 0

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localeManager = LocaleManager.shared

    var body: some View {
        Group {
            if let state = state {
                if state.isOnboarded {
                    MainTabView(state: state)
                } else {
                    NavigationStack(path: $onboardingPath) {
                        WelcomeView {
                            onboardingPath.append(OnboardingRoute.profileSetup)
                        }
                        .navigationDestination(for: OnboardingRoute.self) { destination in
                            switch destination {
                            case .profileSetup:
                                ProfileSetupView(
                                    age: $onboardingVM.age,
                                    sex: $onboardingVM.sex,
                                    heightCm: $onboardingVM.heightCm,
                                    weightKg: $onboardingVM.weightKg,
                                    onBack: { onboardingPath.removeLast() },
                                    onContinue: { onboardingPath.append(OnboardingRoute.goalSetup) }
                                )
                                .id(profileSetupID)
                            case .goalSetup:
                                GoalSetupView(
                                    activityLevel: $onboardingVM.activityLevel,
                                    goal: $onboardingVM.goal,
                                    bmr: onboardingVM.calculatedTarget.bmr,
                                    onBack: { onboardingPath.removeLast() },
                                    onCalculate: { onboardingPath.append(OnboardingRoute.result) }
                                )
                            case .result:
                                CalorieResultView(
                                    target: onboardingVM.calculatedTarget,
                                    onBack: { onboardingPath.removeLast() },
                                    onCreateMealPlan: {
                                        let profile = onboardingVM.currentProfile
                                        state.saveProfile(profile)
                                        state.calculateAndSaveTarget(for: profile)
                                        state.createTodayMealPlan()
                                    },
                                    onEditProfile: {
                                        profileSetupID &+= 1
                                        onboardingPath.removeLast(2)
                                    }
                                )
                            }
                        }
                    }
                    .tint(FoodiaryDesign.pulsePrimary)
                }
            } else {
                VStack {
                    Text("🥗")
                        .font(.system(size: 64))
                    Text(L10n["app.name"])
                        .font(FoodiaryTypography.display)
                        .foregroundColor(FoodiaryDesign.pulseInk)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(FoodiaryDesign.pulseBackground)
            }
        }
        .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        .environmentObject(localeManager)
        .environmentObject(themeManager)
        .onAppear {
            let persistence = SwiftDataPersistenceService(context: modelContext)
            state = AppState(persistence: persistence)
        }
    }
}
