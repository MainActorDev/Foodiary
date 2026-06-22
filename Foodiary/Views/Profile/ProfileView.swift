import SwiftUI

struct ProfileView: View {
    @Bindable var state: AppState
    @State private var showEdit = false
    @State private var showResetConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PulseTopbar(overline: "ESTIMATE CONTEXT", title: L10n["nav.profile"], icon: .user)
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
                                    .fill(
                                        LinearGradient(
                                            colors: [FoodiaryDesign.pulsePrimary, Color(hex: "06B6D4")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: FoodiaryDesign.pulsePrimary.opacity(0.22), radius: 18, x: 0, y: 8)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your planning estimate")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(FoodiaryDesign.pulseInk)
                            Text("Based on profile details and selected planning preference.")
                                .font(.system(size: 12))
                                .foregroundColor(FoodiaryDesign.pulseMuted)
                        }
                    }

                    // Target box
                    if let target = state.calorieTarget {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(target.targetCalories)")
                                .font(.system(size: 46, weight: .bold, design: .rounded))
                                .foregroundColor(FoodiaryDesign.pulsePrimary)
                            Text("KCAL PER DAY ESTIMATE")
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
                                detailRow(label: "Activity", value: profile.activityLevel.localizedDisplayName)
                                detailRow(label: "Preference", value: profile.goal.localizedDisplayName)
                            }
                            detailRow(label: "BMR", value: "\(target.bmr) kcal")
                            detailRow(label: "Maintenance", value: "\(target.maintenanceCalories) kcal")
                        }
                        .padding(.top, 12)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(FoodiaryDesign.pulseSurface)
                        .shadow(color: Color(hex: "141428").opacity(0.055), radius: 30, x: 0, y: 14)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color(hex: "15142A").opacity(0.10), lineWidth: 1)
                )

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

                Button(action: { showResetConfirm = true }) {
                    Text(L10n["action.reset_data"])
                }
                .buttonStyle(PulsePrimaryButtonStyle(bgColor: FoodiaryDesign.pulseDanger, fgColor: .white))
            }
            .padding(18)
        }
        .background(FoodiaryDesign.pulseBackground)
        .sheet(isPresented: $showEdit) {
            NavigationStack {
                ProfileEditView(state: state, isPresented: $showEdit)
                    .modifier(RingNavBarModifier())
            }
        }
        .alert(L10n["alert.reset_title"], isPresented: $showResetConfirm) {
            Button(L10n["alert.cancel"], role: .cancel) { }
            Button(L10n["alert.reset_confirm"], role: .destructive) { state.resetAll() }
        } message: {
            Text(L10n["alert.reset_message"])
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
                .foregroundColor(Color(hex: "15142A").opacity(0.10)),
            alignment: .top
        )
    }
}

struct ProfileEditView: View {
    @Bindable var state: AppState
    @Binding var isPresented: Bool

    @State private var age: Int = 30
    @State private var sex: UserProfile.Sex = .female
    @State private var heightCm: Double = 170
    @State private var weightKg: Double = 70
    @State private var activityLevel: UserProfile.ActivityLevel = .sedentary
    @State private var goal: UserProfile.Goal = .maintain

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.age"]).pulseSectionLabel()
                    IntStepperField(value: $age, range: 1...120)
                }
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
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.height_cm"]).pulseSectionLabel()
                    StepperField(value: $heightCm, range: 50...250)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.weight_kg"]).pulseSectionLabel()
                    StepperField(value: $weightKg, range: 20...300)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.activity_level"]).pulseSectionLabel()
                    VStack(spacing: 2) {
                        ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { option in
                            Button(action: { activityLevel = option }) {
                                Text(option.localizedDisplayName.uppercased()).nbSegment(isActive: activityLevel == option)
                            }
                        }
                    }
                    .padding(3)
                    .background(FoodiaryDesign.pulseSurfaceSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1))
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.goal"]).pulseSectionLabel()
                    VStack(spacing: 3) {
                        ForEach(UserProfile.Goal.allCases, id: \.self) { option in
                            Button(action: { goal = option }) {
                                Text(option.localizedDisplayName.uppercased()).nbSegment(isActive: goal == option)
                            }
                        }
                    }
                    .padding(3)
                    .background(FoodiaryDesign.pulseSurfaceSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1))
                }
                Button(action: saveEdits) { Text(L10n["action.save_recalculate"]) }
                    .buttonStyle(PulsePrimaryButtonStyle())
                Button(action: { isPresented = false }) { Text(L10n["action.cancel"]) }
                    .buttonStyle(PulseSecondaryButtonStyle())
            }
            .padding(20)
        }
        .background(FoodiaryDesign.pulseBackground)
        .navigationTitle(L10n["nav.edit_profile"])
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                }
                .buttonStyle(PulseIconButtonStyle(fgColor: FoodiaryDesign.pulseMuted))
            }
        }
        .onAppear {
            if let profile = state.userProfile {
                age = profile.age; sex = profile.sex
                heightCm = profile.heightCm; weightKg = profile.weightKg
                activityLevel = profile.activityLevel; goal = profile.goal
            }
        }
    }

    private func saveEdits() {
        var profile = state.userProfile ?? UserProfile()
        profile.age = age; profile.sex = sex
        profile.heightCm = heightCm; profile.weightKg = weightKg
        profile.activityLevel = activityLevel; profile.goal = goal
        state.saveProfile(profile)
        state.calculateAndSaveTarget(for: profile)
        isPresented = false
    }
}
