import SwiftUI

struct GoalSetupView: View {
    @Binding var activityLevel: UserProfile.ActivityLevel
    @Binding var goal: UserProfile.Goal
    var onBack: () -> Void
    var onCalculate: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress dots
                HStack(spacing: 8) {
                    Circle().fill(FoodiaryDesign.pulsePrimary.opacity(0.4)).frame(width: 10, height: 10)
                    Circle().fill(FoodiaryDesign.pulsePrimary).frame(width: 28, height: 10)
                    Circle().fill(FoodiaryDesign.pulseSurfaceSoft).frame(width: 10, height: 10)
                }

                // Activity Level
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.activity_level"]).pulseSectionLabel()
                    VStack(spacing: 2) {
                        ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { option in
                            Button(action: { activityLevel = option }) {
                                Text(option.displayName.uppercased())
                                    .nbSegment(isActive: activityLevel == option)
                            }
                        }
                    }
                    .padding(3)
                    .background(FoodiaryDesign.pulseSurfaceSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1))
                }

                // Goal
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.goal"]).pulseSectionLabel()
                    VStack(spacing: 3) {
                        ForEach(UserProfile.Goal.allCases, id: \.self) { option in
                            Button(action: { goal = option }) {
                                Text(option.displayName.uppercased())
                                    .nbSegment(isActive: goal == option)
                            }
                        }
                    }
                    .padding(3)
                    .background(FoodiaryDesign.pulseSurfaceSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1))

                    Text(L10n["onboarding.goal.note"])
                        .font(FoodiaryTypography.pulseCaption)
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }

                Spacer(minLength: 24)

                Button(action: onCalculate) {
                    Text(L10n["action.calculate_target"])
                }
                .buttonStyle(PulsePrimaryButtonStyle())
            }
            .padding(20)
        }
        .background(FoodiaryDesign.pulseBackground)
        .navigationTitle("Your Goal")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(PulseIconButtonStyle(fgColor: FoodiaryDesign.pulseMuted))
            }
        }
    }
}
