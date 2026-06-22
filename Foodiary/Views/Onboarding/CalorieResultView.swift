import SwiftUI

struct CalorieResultView: View {
    let target: CalorieTarget
    var onBack: () -> Void
    var onCreateMealPlan: () -> Void
    var onEditProfile: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(L10n["onboarding.result.title"])
                .font(FoodiaryTypography.pulseCaption)
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .padding(.bottom, 8)

            Text("\(target.targetCalories)")
                .font(FoodiaryTypography.pulseDisplay)
                .foregroundColor(FoodiaryDesign.pulsePrimary)

            Text(L10n["unit.kcal_per_day"])
                .font(FoodiaryTypography.pulseTitle)
                .foregroundColor(FoodiaryDesign.pulseInk)
                .padding(.bottom, 24)

            // Stat cards
            HStack(spacing: 12) {
                StatCard(value: "\(target.bmr)", label: L10n["label.bmr"])
                StatCard(value: "\(target.maintenanceCalories)", label: L10n["label.maintenance"])
                StatCard(value: "\(target.targetCalories)", label: L10n["label.target"])
            }
            .padding(.horizontal, 20)

            Text(L10n["onboarding.result.note"])
                .font(FoodiaryTypography.pulseCaption)
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .padding(.top, 16)

            Spacer()

            Button(action: onCreateMealPlan) {
                Text(L10n["action.create_meal_plan"])
            }
            .buttonStyle(PulsePrimaryButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            Button(action: onEditProfile) {
                Text(L10n["action.edit_profile"])
            }
            .buttonStyle(PulseSecondaryButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            Text(L10n["disclaimer.full"])
                .font(.system(size: 11))
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .multilineTextAlignment(.center)
                .italic()
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FoodiaryDesign.pulseBackground)
        .navigationTitle("Your Target")
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

struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(FoodiaryTypography.pulseBodyBold)
                .foregroundColor(FoodiaryDesign.pulseInk)
            Text(label)
                .font(FoodiaryTypography.pulseLabel)
                .foregroundColor(FoodiaryDesign.pulseMuted)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(FoodiaryDesign.pulseSurface)
                .shadow(color: FoodiaryDesign.pulsePrimaryDark.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
        )
    }
}
