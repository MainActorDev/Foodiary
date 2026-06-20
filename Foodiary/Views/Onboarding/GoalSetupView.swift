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
                    Circle().fill(FoodiaryDesign.muted).frame(width: 10, height: 10).overlay(Circle().stroke(FoodiaryDesign.black, lineWidth: 2))
                    Circle().fill(FoodiaryDesign.coral).frame(width: 28, height: 10)
                    Circle().fill(FoodiaryDesign.muted).frame(width: 10, height: 10).overlay(Circle().stroke(FoodiaryDesign.black, lineWidth: 2))
                }
                
                // Activity Level
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.activity_level"]).sectionLabel()
                    VStack(spacing: 2) {
                        ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { option in
                            Button(action: { activityLevel = option }) {
                                Text(option.localizedDisplayName.uppercased())
                                    .nbSegment(isActive: activityLevel == option)
                            }
                        }
                    }
                    .padding(3)
                    .background(FoodiaryDesign.muted)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.black, lineWidth: 3))
                }
                
                // Goal
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.goal"]).sectionLabel()
                    VStack(spacing: 3) {
                        ForEach(UserProfile.Goal.allCases, id: \.self) { option in
                            Button(action: { goal = option }) {
                                Text(option.localizedDisplayName.uppercased())
                                    .nbSegment(isActive: goal == option)
                            }
                        }
                    }
                    .padding(3)
                    .background(FoodiaryDesign.muted)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.black, lineWidth: 3))
                    
                    Text(L10n["onboarding.goal.note"])
                        .font(.system(size: 12))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                }
                
                Spacer(minLength: 24)
                
                Button(action: onCalculate) {
                    Text(L10n["action.calculate_target"])
                }
                .buttonStyle(NBButtonStyle())
            }
            .padding(20)
        }
        .background(FoodiaryDesign.background)
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
                .buttonStyle(NBStepperButtonStyle())
            }
        }
    }
}
