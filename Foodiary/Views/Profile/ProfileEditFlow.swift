import SwiftUI

/// Edit-profile flow that reuses the onboarding views (ProfileSetup → GoalSetup → CalorieResult)
/// pre-filled with the current profile. Shown as a sheet from ProfileView.
struct ProfileEditFlow: View {
    @EnvironmentObject private var localeManager: LocaleManager
    @Bindable var state: AppState
    @Binding var isPresented: Bool

    @State private var path = NavigationPath()
    @State private var editVM = OnboardingViewModel()
    @State private var profileSetupID = 0
    @State private var didLoad = false

    var body: some View {
        NavigationStack(path: $path) {
            ProfileSetupView(
                age: $editVM.age,
                sex: $editVM.sex,
                heightCm: $editVM.heightCm,
                weightKg: $editVM.weightKg,
                onBack: { isPresented = false },
                onContinue: { path.append(EditRoute.goalSetup) }
            )
            .id(profileSetupID)
            .navigationDestination(for: EditRoute.self) { destination in
                switch destination {
                case .goalSetup:
                    GoalSetupView(
                        activityLevel: $editVM.activityLevel,
                        goal: $editVM.goal,
                        bmr: editVM.calculatedTarget.bmr,
                        onBack: { path.removeLast() },
                        onCalculate: { path.append(EditRoute.result) }
                    )
                case .result:
                    CalorieResultView(
                        target: editVM.calculatedTarget,
                        onBack: { path.removeLast() },
                        onCreateMealPlan: {
                            let profile = editVM.currentProfile
                            state.saveProfile(profile)
                            state.calculateAndSaveTarget(for: profile)
                            isPresented = false
                        },
                        onEditProfile: {
                            profileSetupID &+= 1
                            path.removeLast(2)
                        },
                        primaryButtonTitle: L10n["action.save_recalculate"]
                    )
                }
            }
        }
        .tint(FoodiaryDesign.pulsePrimary)
        .onAppear {
            guard !didLoad, let profile = state.userProfile else { return }
            didLoad = true
            editVM.age = profile.age
            editVM.sex = profile.sex
            editVM.heightCm = profile.heightCm
            editVM.weightKg = profile.weightKg
            editVM.activityLevel = profile.activityLevel
            editVM.goal = profile.goal
        }
    }
}

private enum EditRoute: Hashable {
    case goalSetup
    case result
}
