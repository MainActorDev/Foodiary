import SwiftUI

struct ProfileSetupView: View {
    @Binding var age: Int
    @Binding var sex: UserProfile.Sex
    @Binding var heightCm: Double
    @Binding var weightKg: Double
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress dots
                HStack(spacing: 8) {
                    Circle().fill(FoodiaryDesign.pulsePrimary).frame(width: 28, height: 10)
                    Circle().fill(FoodiaryDesign.pulseSurfaceSoft).frame(width: 10, height: 10)
                    Circle().fill(FoodiaryDesign.pulseSurfaceSoft).frame(width: 10, height: 10)
                }

                Text(L10n["onboarding.profile.subtitle"])
                    .font(FoodiaryTypography.pulseCaption)
                    .foregroundColor(FoodiaryDesign.pulseMuted)

                // Age
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.age"]).pulseSectionLabel()
                    IntStepperField(value: $age, range: 1...120)
                }

                // Sex
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.biological_sex"]).pulseSectionLabel()
                    HStack(spacing: 2) {
                        ForEach(UserProfile.Sex.allCases, id: \.self) { option in
                            Button(action: { sex = option }) {
                                Text(option.localizedDisplayName.uppercased())
                                    .nbSegment(isActive: sex == option)
                            }
                        }
                    }
                    .padding(3)
                    .background(FoodiaryDesign.pulseSurfaceSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1))
                    Text(L10n["onboarding.profile.sex_note"])
                        .font(FoodiaryTypography.pulseCaption)
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }

                // Height
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.height_cm"]).pulseSectionLabel()
                    StepperField(value: $heightCm, range: 50...250, step: 1)
                }

                // Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.weight_kg"]).pulseSectionLabel()
                    StepperField(value: $weightKg, range: 20...300, step: 1)
                }

                Spacer(minLength: 24)

                Button(action: onContinue) {
                    Text(L10n["action.continue"])
                }
                .buttonStyle(PulsePrimaryButtonStyle())
            }
            .padding(20)
        }
        .background(FoodiaryDesign.pulseBackground)
        .navigationTitle("About You")
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
            .buttonStyle(PulseIconButtonStyle(fgColor: FoodiaryDesign.pulseInk))

            Text("\(Int(value))")
                .font(FoodiaryTypography.pulseMetric)
                .foregroundColor(FoodiaryDesign.pulseInk)
                .frame(minWidth: 48)

            Button(action: { value = min(range.upperBound, value + step) }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(PulseIconButtonStyle(fgColor: FoodiaryDesign.pulseInk))
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(FoodiaryDesign.pulseSurfaceSoft)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1))
    }
}
