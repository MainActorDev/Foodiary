import SwiftUI

struct ProfileSetupView: View {
    @Binding var age: Int
    @Binding var sex: UserProfile.Sex
    @Binding var heightCm: Double
    @Binding var weightKg: Double
    var onContinue: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress dots
                HStack(spacing: 8) {
                    Circle().fill(FoodiaryDesign.coral).frame(width: 28, height: 10)
                    Circle().fill(FoodiaryDesign.muted).frame(width: 10, height: 10).overlay(Circle().stroke(FoodiaryDesign.black, lineWidth: 2))
                    Circle().fill(FoodiaryDesign.muted).frame(width: 10, height: 10).overlay(Circle().stroke(FoodiaryDesign.black, lineWidth: 2))
                }
                
                Text(L10n["onboarding.profile.subtitle"])
                    .font(FoodiaryTypography.bodySm)
                    .foregroundColor(FoodiaryDesign.mutedFg)
                
                // Age
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.age"]).sectionLabel()
                    IntStepperField(value: $age, range: 1...120)
                }
                
                // Sex
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.biological_sex"]).sectionLabel()
                    HStack(spacing: 2) {
                        ForEach(UserProfile.Sex.allCases, id: \.self) { option in
                            Button(action: { sex = option }) {
                                Text(option.localizedDisplayName.uppercased())
                                    .nbSegment(isActive: sex == option)
                            }
                        }
                    }
                    .padding(3)
                    .background(FoodiaryDesign.muted)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.black, lineWidth: 3))
                    Text(L10n["onboarding.profile.sex_note"])
                        .font(.system(size: 12))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                }
                
                // Height
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.height_cm"]).sectionLabel()
                    StepperField(value: $heightCm, range: 50...250, step: 1)
                }
                
                // Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.weight_kg"]).sectionLabel()
                    StepperField(value: $weightKg, range: 20...300, step: 1)
                }
                
                Spacer(minLength: 24)
                
                Button(action: onContinue) {
                    Text(L10n["action.continue"])
                }
                .buttonStyle(NBButtonStyle())
            }
            .padding(20)
        }
        .background(FoodiaryDesign.background)
        .navigationTitle(L10n["nav.about_you"])
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StepperField: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double = 1
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: { value = max(range.lowerBound, value - step) }) {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(NBStepperButtonStyle())
            
            Text("\(Int(value))")
                .font(FoodiaryTypography.metric)
                .foregroundColor(FoodiaryDesign.black)
                .frame(minWidth: 48)
            
            Button(action: { value = min(range.upperBound, value + step) }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(NBStepperButtonStyle())
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(FoodiaryDesign.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.black, lineWidth: 3))
    }
}

struct NeubrutalistStepperButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(FoodiaryDesign.black)
            .background(FoodiaryDesign.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(FoodiaryDesign.black, lineWidth: 2))
            .shadow(color: FoodiaryDesign.black, radius: 0, x: configuration.isPressed ? 1 : 2, y: configuration.isPressed ? 1 : 2)
            .offset(x: configuration.isPressed ? 1 : 0, y: configuration.isPressed ? 1 : 0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
