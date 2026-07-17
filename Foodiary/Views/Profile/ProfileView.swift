import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    @Bindable var state: AppState
    @State private var showEdit = false
    @State private var showSettings = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PulseTopbar(overline: L10n["profile.overline"], title: L10n["nav.profile"], icon: .gear) {
                    showSettings = true
                }

                // Single unified card (prototype: .white-card)
                VStack(spacing: 0) {
                    // Profile head: avatar + heading
                    HStack(spacing: 14) {
                        // Avatar
                        Text("FD")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                            .frame(width: 58, height: 58)
                            .background(
                                RoundedRectangle(cornerRadius: 21, style: .continuous)
                                    .fill(FoodiaryDesign.pulseAvatarGradient)
                                    .shadow(color: FoodiaryDesign.pulsePrimary.opacity(0.22), radius: 18, x: 0, y: 8)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n["profile.your_planning_estimate"])
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(FoodiaryDesign.pulseInk)
                            Text(L10n["profile.based_on_details"])
                                .font(.system(size: 12))
                                .foregroundColor(FoodiaryDesign.pulseMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    // Target box
                    if let target = state.calorieTarget {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(String(format: "%.1f", target.targetCalories))")
                                .font(.system(size: 46, weight: .bold, design: .rounded))
                                .foregroundColor(FoodiaryDesign.pulsePrimary)
                            Text(L10n["profile.kcal_per_day"])
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(FoodiaryDesign.pulseMuted)
                                .tracking(0.6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(FoodiaryDesign.pulseSurfaceSoft)
                        )
                        .padding(.top, 16)

                        // Detail rows
                        VStack(spacing: 0) {
                            if let profile = state.userProfile {
                                let userBmi = CalorieCalculator.bmi(weightKg: profile.weightKg, heightCm: profile.heightCm)
                                let bmiCat = CalorieCalculator.bmiCategory(userBmi)
                                let idealW = CalorieCalculator.idealWeightRange(heightCm: profile.heightCm)
                                bmiDetailRow(bmi: userBmi, category: bmiCat)
                                idealWeightRow(minKg: idealW.minKg, maxKg: idealW.maxKg)
                                detailRow(label: L10n["label.profile_activity"], value: profile.activityLevel.displayName)
                                detailRow(label: L10n["label.profile_preference"], value: profile.goal.displayName)
                            }
                            detailRow(label: L10n["label.bmr"], value: "\(String(format: "%.1f", target.bmr)) kcal")
                            detailRow(label: L10n["label.profile_maintenance"], value: "\(String(format: "%.1f", target.maintenanceCalories)) kcal")
                        }
                        .padding(.top, 12)
                    }
                }
                .pulseCard(cornerRadius: 26, padding: 16)

                // Disclaimer
                Text(L10n["disclaimer.full"])
                    .font(.system(size: 11))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
                    .multilineTextAlignment(.center)
                    .italic()
                    .padding(.horizontal, 4)

                // Actions
                Button(action: { showEdit = true }) {
                    Text(L10n["action.edit_profile"])
                }
                .buttonStyle(PulseSecondaryButtonStyle())
            }
            .padding(18)
        }
        .background(FoodiaryDesign.pulseBackground)
        .toolbar(showSettings ? .visible : .hidden, for: .navigationBar)
        .toolbar(showSettings ? .hidden : .visible, for: .tabBar)
        .animation(.easeInOut(duration: 0.25), value: showSettings)
        .sheet(isPresented: $showEdit) {
            ProfileEditFlow(state: state, isPresented: $showEdit)
                .environmentObject(localeManager)
                .environmentObject(ThemeManager.shared)
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView(state: state)
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(FoodiaryDesign.pulseMuted)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(FoodiaryDesign.pulseInk)
        }
        .padding(.vertical, 13)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(FoodiaryDesign.pulseStroke.opacity(0.10)),
            alignment: .top
        )
    }

    private func idealWeightRow(minKg: Double, maxKg: Double) -> some View {
        HStack {
            Text(L10n["label.ideal_weight"])
                .font(.system(size: 13))
                .foregroundColor(FoodiaryDesign.pulseMuted)
            Spacer()
            Text("\(String(format: "%.1f", minKg)) – \(String(format: "%.1f", maxKg)) kg")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(FoodiaryDesign.pulseInk)
        }
        .padding(.vertical, 13)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(FoodiaryDesign.pulseStroke.opacity(0.10)),
            alignment: .top
        )
    }

    private func bmiDetailRow(bmi: Double, category: CalorieCalculator.BMICategory) -> some View {
        HStack {
            Text(L10n["label.bmi"])
                .font(.system(size: 13))
                .foregroundColor(FoodiaryDesign.pulseMuted)
            Spacer()
            Text(String(format: "%.1f", bmi))
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(FoodiaryDesign.pulseInk)
            Text(bmiCategoryDisplayName(category))
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(bmiCategoryColor(category))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(bmiCategoryColor(category).opacity(0.12))
                )
                .padding(.leading, 6)
        }
        .padding(.vertical, 13)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(FoodiaryDesign.pulseStroke.opacity(0.10)),
            alignment: .top
        )
    }

    private func bmiCategoryDisplayName(_ category: CalorieCalculator.BMICategory) -> String {
        switch category {
        case .underweight: return L10n["bmi.category.underweight"]
        case .normal: return L10n["bmi.category.normal"]
        case .overweight: return L10n["bmi.category.overweight"]
        case .obese: return L10n["bmi.category.obese"]
        }
    }

    private func bmiCategoryColor(_ category: CalorieCalculator.BMICategory) -> Color {
        switch category {
        case .underweight: return Color(hex: "3B82F6")
        case .normal: return FoodiaryDesign.pulseMint
        case .overweight: return FoodiaryDesign.pulseAmber
        case .obese: return FoodiaryDesign.pulseDanger
        }
    }
}
