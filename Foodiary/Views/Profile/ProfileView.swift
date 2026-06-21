import SwiftUI

struct ProfileView: View {
    @Bindable var state: AppState
    @State private var showEdit = false
    @State private var showResetConfirm = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let profile = state.userProfile {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(L10n["profile.your_details"])
                            .sectionLabel()
                            .padding(.bottom, 12)
                        
                        ProfileRow(label: L10n["label.profile_age"], value: "\(profile.age)")
                        ProfileRow(label: L10n["label.profile_sex"], value: profile.sex.localizedDisplayName)
                        ProfileRow(label: L10n["label.profile_height"], value: "\(Int(profile.heightCm)) cm")
                        ProfileRow(label: L10n["label.profile_weight"], value: "\(Int(profile.weightKg)) kg")
                        ProfileRow(label: L10n["label.profile_activity"], value: profile.activityLevel.localizedDisplayName)
                        ProfileRow(label: L10n["label.profile_goal"], value: profile.goal.localizedDisplayName)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .nbCard()
                }
                
                if let target = state.calorieTarget {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n["profile.calorie_target"])
                            .sectionLabel()
                            .padding(.bottom, 4)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("\(target.targetCalories)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(FoodiaryDesign.coral)
                            Text(L10n["unit.kcal_per_day_compact"])
                                .font(FoodiaryTypography.bodySm)
                                .foregroundColor(FoodiaryDesign.mutedFg)
                        }
                        
                        HStack(spacing: 12) {
                            (Text(L10n["profile.bmr_prefix"]).foregroundColor(FoodiaryDesign.mutedFg) + Text("\(target.bmr)").bold().foregroundColor(FoodiaryDesign.black))
                            (Text(L10n["profile.maintenance_prefix"]).foregroundColor(FoodiaryDesign.mutedFg) + Text("\(target.maintenanceCalories)").bold().foregroundColor(FoodiaryDesign.black))
                        }
                        .font(.system(size: 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .nbCard()
                }
                
                Text(L10n["disclaimer.full"])
                    .font(.system(size: 11))
                    .foregroundColor(FoodiaryDesign.mutedFg)
                    .multilineTextAlignment(.center)
                    .italic()
                    .padding(.horizontal, 8)
                
                Button(action: { showEdit = true }) {
                    Text(L10n["action.edit_profile"])
                }
                .buttonStyle(NBSecondaryButtonStyle())
                
                
                Button(action: { showResetConfirm = true }) {
                    Text(L10n["action.reset_data"])
                }
                .buttonStyle(NBButtonStyle(bgColor: FoodiaryDesign.coral, fgColor: .white))
            }
            .padding(20)
        }
        .background(FoodiaryDesign.background)
        .sheet(isPresented: $showEdit) {
            NavigationStack {
                ProfileEditView(state: state, isPresented: $showEdit)
                    .modifier(NBNavBarModifier())
            }
        }
        .alert(L10n["alert.reset_title"], isPresented: $showResetConfirm) {
            Button(L10n["alert.cancel"], role: .cancel) { }
            Button(L10n["alert.reset_confirm"], role: .destructive) { state.resetAll() }
        } message: {
            Text(L10n["alert.reset_message"])
        }
    }
}

struct ProfileRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(FoodiaryTypography.body)
                .foregroundColor(FoodiaryDesign.mutedFg)
            Spacer()
            Text(value)
                .font(FoodiaryTypography.bodyBold)
                .foregroundColor(FoodiaryDesign.black)
        }
        .padding(.vertical, 14)
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(FoodiaryDesign.muted),
            alignment: .bottom
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
                    Text(L10n["label.age"]).sectionLabel()
                    IntStepperField(value: $age, range: 1...120)
                }
                
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
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.border, lineWidth: 1.5))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.height_cm"]).sectionLabel()
                    StepperField(value: $heightCm, range: 50...250)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.weight_kg"]).sectionLabel()
                    StepperField(value: $weightKg, range: 20...300)
                }
                
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
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.border, lineWidth: 1.5))
                }
                
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
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.border, lineWidth: 1.5))
                }
                
                Button(action: saveEdits) {
                    Text(L10n["action.save_recalculate"])
                }
                .buttonStyle(NBButtonStyle())
                
                Button(action: { isPresented = false }) {
                    Text(L10n["action.cancel"])
                }
                .buttonStyle(NBSecondaryButtonStyle())
            }
            .padding(20)
        }
        .background(FoodiaryDesign.background)
        .navigationTitle(L10n["nav.edit_profile"])
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                }
                .buttonStyle(NBStepperButtonStyle())
            }
        }
        .onAppear {
            if let profile = state.userProfile {
                age = profile.age
                sex = profile.sex
                heightCm = profile.heightCm
                weightKg = profile.weightKg
                activityLevel = profile.activityLevel
                goal = profile.goal
            }
        }
    }
    
    private func saveEdits() {
        var profile = state.userProfile ?? UserProfile()
        profile.age = age
        profile.sex = sex
        profile.heightCm = heightCm
        profile.weightKg = weightKg
        profile.activityLevel = activityLevel
        profile.goal = goal
        state.saveProfile(profile)
        state.calculateAndSaveTarget(for: profile)
        isPresented = false
    }
}
