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
                .font(FoodiaryTypography.bodySm)
                .foregroundColor(FoodiaryDesign.mutedFg)
                .padding(.bottom, 8)
            
            Text("\(target.targetCalories)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(FoodiaryDesign.coral)
            
            Text(L10n["unit.kcal_per_day"])
                .font(FoodiaryTypography.title)
                .foregroundColor(FoodiaryDesign.black)
                .padding(.bottom, 24)
            
            // Stat cards
            HStack(spacing: 12) {
                StatCard(value: "\(target.bmr)", label: L10n["label.bmr"])
                StatCard(value: "\(target.maintenanceCalories)", label: L10n["label.maintenance"])
                StatCard(value: "\(target.targetCalories)", label: L10n["label.target"])
            }
            .padding(.horizontal, 20)
            
            Text(L10n["onboarding.result.note"])
                .font(FoodiaryTypography.bodySm)
                .foregroundColor(FoodiaryDesign.mutedFg)
                .padding(.top, 16)
            
            Spacer()
            
            Button(action: onCreateMealPlan) {
                Text(L10n["action.create_meal_plan"])
            }
            .buttonStyle(NBButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            Button(action: onEditProfile) {
                Text(L10n["action.edit_profile"])
            }
            .buttonStyle(NBSecondaryButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            Text(L10n["disclaimer.full"])
                .font(.system(size: 11))
                .foregroundColor(FoodiaryDesign.mutedFg)
                .multilineTextAlignment(.center)
                .italic()
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FoodiaryDesign.background)
        .navigationTitle(L10n["nav.your_target"])
        .navigationBarTitleDisplayMode(.inline)
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

struct StatCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(FoodiaryTypography.bodyBold)
                .foregroundColor(FoodiaryDesign.black)
            Text(label)
                .font(FoodiaryTypography.label)
                .foregroundColor(FoodiaryDesign.mutedFg)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(FoodiaryDesign.black)
                    .offset(x: 2, y: 2)
                RoundedRectangle(cornerRadius: 12)
                    .fill(FoodiaryDesign.white)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(FoodiaryDesign.black, lineWidth: 2)
            }
        )
    }
}
