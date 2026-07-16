import SwiftUI

struct GoalSetupView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    @Binding var activityLevel: UserProfile.ActivityLevel
    @Binding var goal: UserProfile.Goal
    let bmr: Int
    var onBack: () -> Void
    var onCalculate: () -> Void

    @State private var activeQuestion: Question = .activity

    enum Question: Int, CaseIterable {
        case activity, goal
        var next: Question? { Question(rawValue: rawValue + 1) }
    }

    private var estimatedMaintenance: Int {
        Int(Double(bmr) * activityLevel.multiplier)
    }

    private var estimatedTarget: Int {
        Int(Double(estimatedMaintenance) * goal.multiplier)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar — 2 segments
            HStack(spacing: 6) {
                ForEach(Question.allCases, id: \.self) { question in
                    Capsule()
                        .fill(question.rawValue <= activeQuestion.rawValue
                              ? FoodiaryDesign.pulsePrimary
                              : FoodiaryDesign.pulseSurfaceSoft)
                        .frame(height: 4)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activeQuestion)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)

            Spacer()

            // Main display — switches between activity and goal
            Group {
                switch activeQuestion {
                case .activity: activityDisplay
                case .goal: goalDisplay
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .id(activeQuestion)

            Spacer()

            // Navigation buttons
            HStack(spacing: 12) {
                if activeQuestion.rawValue > 0 {
                    Button(action: goBack) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(FoodiaryDesign.pulseInk)
                            .frame(width: 52, height: 52)
                            .background(Circle().fill(FoodiaryDesign.pulseSurfaceSoft))
                    }
                }

                Button(action: nextTapped) {
                    HStack(spacing: 8) {
                        Text(activeQuestion == .goal
                             ? L10n["action.calculate_target"]
                             : L10n["action.continue"])
                        Image(systemName: activeQuestion == .goal ? "checkmark" : "arrow.right")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(FoodiaryDesign.pulsePrimary)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FoodiaryDesign.pulseBackground)
        .navigationTitle(L10n["onboarding.goal.title"])
        .navigationBarTitleDisplayMode(.inline)
        .pulseBackButton(action: onBack)
    }

    // MARK: - Navigation

    private func goBack() {
        if let prev = Question(rawValue: activeQuestion.rawValue - 1) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                activeQuestion = prev
            }
        }
    }

    private func nextTapped() {
        if let nextQuestion = activeQuestion.next {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                activeQuestion = nextQuestion
            }
        } else {
            onCalculate()
        }
    }

    // MARK: - Activity Level Display (3 cards in column)

    private var activityDisplay: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(L10n["label.activity_level"])
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
                    .tracking(3)

                Text(L10n["onboarding.activity.subtitle"])
                    .font(FoodiaryTypography.pulseCaption)
                    .foregroundColor(FoodiaryDesign.pulseMuted)
            }
            .padding(.bottom, 4)

            VStack(spacing: 10) {
                ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { option in
                    ActivityCard(
                        option: option,
                        isSelected: activityLevel == option,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                activityLevel = option
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Goal Display (3 stacked cards + live preview)

    private var goalDisplay: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(L10n["label.goal"])
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
                    .tracking(3)

                Text(L10n["onboarding.goal.subtitle"])
                    .font(FoodiaryTypography.pulseCaption)
                    .foregroundColor(FoodiaryDesign.pulseMuted)
            }
            .padding(.bottom, 4)

            VStack(spacing: 10) {
                ForEach(UserProfile.Goal.allCases, id: \.self) { option in
                    GoalCard(
                        option: option,
                        isSelected: goal == option,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                goal = option
                            }
                        }
                    )
                }
            }

            // Live target preview
            VStack(spacing: 6) {
                Text(L10n["onboarding.result.title"])
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text("~\(estimatedTarget)")
                    .font(.system(size: 36, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundColor(.white)

                Text(L10n["unit.kcal_per_day"])
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.55))

                if goal != .maintain {
                    Text(goal == .lose ? L10n["onboarding.result.lose_badge"] : L10n["onboarding.result.gain_badge"])
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(goal == .lose ? Color(hex: "6EE7B7") : Color(hex: "FCD34D"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill((goal == .lose ? FoodiaryDesign.pulseMint : FoodiaryDesign.pulseAmber).opacity(0.2))
                        )
                        .padding(.top, 2)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [FoodiaryDesign.pulsePrimaryDark, Color(hex: "0A4070")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Activity Card

private struct ActivityCard: View {
    let option: UserProfile.ActivityLevel
    let isSelected: Bool
    let action: () -> Void

    private var emoji: String {
        switch option {
        case .sedentary: return "🪑"
        case .lightlyActive: return "🚶"
        case .active: return "🏃"
        case .veryActive: return "🏋️"
        }
    }

    private var description: String {
        switch option {
        case .sedentary: return L10n["model.activity.sedentary.desc"]
        case .lightlyActive: return L10n["model.activity.lightly_active.desc"]
        case .active: return L10n["model.activity.active.desc"]
        case .veryActive: return L10n["model.activity.very_active.desc"]
        }
    }

    private var multiplierText: String {
        String(format: "×%.1f", option.multiplier)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 28))
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isSelected ? FoodiaryDesign.pulsePrimaryLight : FoodiaryDesign.pulseSurfaceSoft)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.displayName)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? FoodiaryDesign.pulsePrimaryDark : FoodiaryDesign.pulseInk)

                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }

                Spacer()

                Text(multiplierText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isSelected ? FoodiaryDesign.pulsePrimary : FoodiaryDesign.pulseMuted)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isSelected ? FoodiaryDesign.pulsePrimaryLight : FoodiaryDesign.pulseSurfaceSoft)
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(FoodiaryDesign.pulseSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isSelected ? FoodiaryDesign.pulsePrimary : FoodiaryDesign.pulseBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Goal Card (stacked rows)

private struct GoalCard: View {
    let option: UserProfile.Goal
    let isSelected: Bool
    let action: () -> Void

    private var emoji: String {
        switch option {
        case .lose: return "📉"
        case .maintain: return "⚖️"
        case .gain: return "📈"
        }
    }

    private var description: String {
        switch option {
        case .lose: return L10n["model.goal.lose.desc"]
        case .maintain: return L10n["model.goal.maintain.desc"]
        case .gain: return L10n["model.goal.gain.desc"]
        }
    }

    private var effectText: String {
        switch option {
        case .lose: return "−10%"
        case .maintain: return "0%"
        case .gain: return "+10%"
        }
    }

    private var effectColor: Color {
        switch option {
        case .lose: return FoodiaryDesign.pulseMint
        case .maintain: return FoodiaryDesign.pulseMuted
        case .gain: return FoodiaryDesign.pulseAmber
        }
    }

    private var effectBg: Color {
        switch option {
        case .lose: return FoodiaryDesign.pulseMintLight
        case .maintain: return FoodiaryDesign.pulseSurfaceSoft
        case .gain: return FoodiaryDesign.pulseAmberLight
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 24))
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isSelected ? FoodiaryDesign.pulsePrimaryLight : FoodiaryDesign.pulseSurfaceSoft)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.displayName)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? FoodiaryDesign.pulsePrimaryDark : FoodiaryDesign.pulseInk)

                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }

                Spacer()

                Text(effectText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(effectColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(effectBg))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(FoodiaryDesign.pulseSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isSelected ? FoodiaryDesign.pulsePrimary : FoodiaryDesign.pulseBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
