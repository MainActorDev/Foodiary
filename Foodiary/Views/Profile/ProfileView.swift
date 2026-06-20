import SwiftUI

struct ProfileView: View {
    @ObservedObject var state: AppState
    @State private var showEdit = false
    @State private var showResetConfirm = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let profile = state.userProfile {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("YOUR DETAILS")
                            .sectionLabel()
                            .padding(.bottom, 12)
                        
                        ProfileRow(label: "Age", value: "\(profile.age)")
                        ProfileRow(label: "Sex", value: profile.sex.displayName)
                        ProfileRow(label: "Height", value: "\(Int(profile.heightCm)) cm")
                        ProfileRow(label: "Weight", value: "\(Int(profile.weightKg)) kg")
                        ProfileRow(label: "Activity", value: profile.activityLevel.displayName)
                        ProfileRow(label: "Goal", value: profile.goal.displayName)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .nbCard()
                }
                
                if let target = state.calorieTarget {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CALORIE TARGET")
                            .sectionLabel()
                            .padding(.bottom, 4)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("\(target.targetCalories)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(FoodiaryDesign.coral)
                            Text("kcal/day")
                                .font(FoodiaryTypography.bodySm)
                                .foregroundColor(FoodiaryDesign.mutedFg)
                        }
                        
                        HStack(spacing: 12) {
                            (Text("BMR ").foregroundColor(FoodiaryDesign.mutedFg) + Text("\(target.bmr)").bold().foregroundColor(FoodiaryDesign.black))
                            (Text("Maintenance ").foregroundColor(FoodiaryDesign.mutedFg) + Text("\(target.maintenanceCalories)").bold().foregroundColor(FoodiaryDesign.black))
                        }
                        .font(.system(size: 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .nbCard()
                }
                
                Text("This is an estimate for planning purposes only. For medical conditions, eating disorders, pregnancy, athletic nutrition, or major weight changes, consult a qualified health professional.")
                    .font(.system(size: 11))
                    .foregroundColor(FoodiaryDesign.mutedFg)
                    .multilineTextAlignment(.center)
                    .italic()
                    .padding(.horizontal, 8)
                
                Button(action: { showEdit = true }) {
                    Text("EDIT PROFILE")
                }
                .buttonStyle(NBSecondaryButtonStyle())
                
                Button(action: { state.recalculateTarget() }) {
                    Text("RECALCULATE TARGET")
                }
                .buttonStyle(NBSecondaryButtonStyle())
                
                Button(action: { showResetConfirm = true }) {
                    Text("RESET DATA")
                }
                .buttonStyle(NBButtonStyle(bgColor: FoodiaryDesign.black, fgColor: .white))
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
        .alert("Reset All Data?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) { state.resetAll() }
        } message: {
            Text("This will delete your profile, calorie target, and all meal plans. This cannot be undone.")
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
    @ObservedObject var state: AppState
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
                    Text("AGE").sectionLabel()
                    IntStepperField(value: $age, range: 1...120)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("BIOLOGICAL SEX").sectionLabel()
                    HStack(spacing: 2) {
                        ForEach(UserProfile.Sex.allCases, id: \.self) { option in
                            Button(action: { sex = option }) {
                                Text(option.displayName.uppercased())
                                    .nbSegment(isActive: sex == option)
                            }
                        }
                    }
                    .padding(3)
                    .background(FoodiaryDesign.muted)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.black, lineWidth: 3))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("HEIGHT (CM)").sectionLabel()
                    StepperField(value: $heightCm, range: 50...250)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("WEIGHT (KG)").sectionLabel()
                    StepperField(value: $weightKg, range: 20...300)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("ACTIVITY LEVEL").sectionLabel()
                    VStack(spacing: 2) {
                        ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { option in
                            Button(action: { activityLevel = option }) {
                                Text(option.displayName.uppercased())
                                    .nbSegment(isActive: activityLevel == option)
                            }
                        }
                    }
                    .padding(3)
                    .background(FoodiaryDesign.muted)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.black, lineWidth: 3))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("GOAL").sectionLabel()
                    VStack(spacing: 3) {
                        ForEach(UserProfile.Goal.allCases, id: \.self) { option in
                            Button(action: { goal = option }) {
                                Text(option.displayName.uppercased())
                                    .nbSegment(isActive: goal == option)
                            }
                        }
                    }
                    .padding(3)
                    .background(FoodiaryDesign.muted)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(FoodiaryDesign.black, lineWidth: 3))
                }
                
                Button(action: saveEdits) {
                    Text("SAVE & RECALCULATE")
                }
                .buttonStyle(NBButtonStyle())
                
                Button(action: { isPresented = false }) {
                    Text("CANCEL")
                }
                .buttonStyle(NBSecondaryButtonStyle())
            }
            .padding(20)
        }
        .background(FoodiaryDesign.background)
        .navigationTitle("Edit Profile")
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
