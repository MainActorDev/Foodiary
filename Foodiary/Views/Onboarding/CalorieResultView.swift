import SwiftUI

struct CalorieResultView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    let target: CalorieTarget
    var onBack: () -> Void
    var onCreateMealPlan: () -> Void
    var onEditProfile: () -> Void
    var primaryButtonTitle: String? = nil

    @State private var barAnimated = false

    private var adjustment: Int { target.targetCalories - target.maintenanceCalories }
    private var isDeficit: Bool { adjustment < 0 }
    private var isSurplus: Bool { adjustment > 0 }
    private var absAdjustment: Int { abs(adjustment) }

    private var maxValue: Int { max(target.maintenanceCalories, target.targetCalories) }

    private var bmrFraction: Double {
        guard maxValue > 0 else { return 0 }
        return Double(target.bmr) / Double(maxValue)
    }
    private var activityFraction: Double {
        guard maxValue > 0 else { return 0 }
        return Double(target.maintenanceCalories - target.bmr) / Double(maxValue)
    }
    private var adjustFraction: Double {
        guard maxValue > 0 else { return 0 }
        return Double(absAdjustment) / Double(maxValue)
    }
    private var targetFraction: Double {
        guard maxValue > 0 else { return 0 }
        return Double(target.targetCalories) / Double(maxValue)
    }
    private var pctOfMaintenance: Int {
        guard target.maintenanceCalories > 0 else { return 0 }
        return Int((Double(target.targetCalories) / Double(target.maintenanceCalories)) * 100)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header — big target number
                VStack(spacing: 4) {
                    Text(L10n["onboarding.result.title"])
                        .font(FoodiaryTypography.pulseCaption)
                        .foregroundColor(FoodiaryDesign.pulseMuted)

                    Text("\(target.targetCalories)")
                        .font(.system(size: 52, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundColor(FoodiaryDesign.pulsePrimary)

                    Text(L10n["unit.kcal_per_day"])
                        .font(FoodiaryTypography.pulseTitle)
                        .foregroundColor(FoodiaryDesign.pulseInk)
                }
                .padding(.top, 8)

                // Energy balance card
                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n["onboarding.result.energy_balance"])
                        .font(FoodiaryTypography.pulseLabel)
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                        .textCase(.uppercase)

                    EnergyBalanceBar(
                        bmrFraction: bmrFraction,
                        activityFraction: activityFraction,
                        adjustFraction: adjustFraction,
                        targetFraction: targetFraction,
                        isSurplus: isSurplus,
                        bmrLabel: "\(target.bmr)",
                        activityLabel: "+\(target.maintenanceCalories - target.bmr)",
                        animate: barAnimated
                    )

                    // Labels under bar
                    BalanceBarLabels(
                        targetLabel: "\(target.targetCalories)",
                        maintenanceLabel: "\(target.maintenanceCalories)"
                    )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(FoodiaryDesign.pulseSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
                )
                .padding(.horizontal, 20)

                // Stat grid 2×2
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    BalanceStatTile(
                        value: "\(target.bmr)",
                        label: L10n["label.bmr"],
                        accentColor: FoodiaryDesign.pulsePrimaryDark
                    )
                    BalanceStatTile(
                        value: "\(target.maintenanceCalories)",
                        label: L10n["label.maintenance"],
                        accentColor: FoodiaryDesign.pulsePrimary
                    )
                    BalanceStatTile(
                        value: isSurplus ? "+\(absAdjustment)" : (isDeficit ? "−\(absAdjustment)" : "0"),
                        label: isSurplus ? L10n["label.surplus"] : (isDeficit ? L10n["label.deficit"] : L10n["label.adjustment"]),
                        accentColor: isSurplus ? FoodiaryDesign.pulseAmber : (isDeficit ? FoodiaryDesign.pulseMint : FoodiaryDesign.pulseMuted)
                    )
                    BalanceStatTile(
                        value: "\(pctOfMaintenance)%",
                        label: L10n["label.of_maintenance"],
                        accentColor: FoodiaryDesign.pulseCyan
                    )
                }
                .padding(.horizontal, 20)

                Text(L10n["onboarding.result.note"])
                    .font(FoodiaryTypography.pulseCaption)
                    .foregroundColor(FoodiaryDesign.pulseMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 4)

                // Buttons
                VStack(spacing: 10) {
                    Button(action: onCreateMealPlan) {
                        Text(primaryButtonTitle ?? L10n["action.create_meal_plan"])
                    }
                    .buttonStyle(PulsePrimaryButtonStyle())

                    Button(action: onEditProfile) {
                        Text(L10n["action.edit_profile"])
                    }
                    .buttonStyle(PulseSecondaryButtonStyle())
                }
                .padding(.horizontal, 20)

                Text(L10n["disclaimer.full"])
                    .font(.system(size: 11))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
                    .multilineTextAlignment(.center)
                    .italic()
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FoodiaryDesign.pulseBackground)
        .navigationTitle(L10n["onboarding.result.title_nav"])
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
        .onAppear {
            // Trigger bar grow animation after a short delay
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                barAnimated = true
            }
        }
    }
}

// MARK: - Energy Balance Bar

private struct EnergyBalanceBar: View {
    let bmrFraction: Double
    let activityFraction: Double
    let adjustFraction: Double
    let targetFraction: Double
    let isSurplus: Bool
    let bmrLabel: String
    let activityLabel: String
    let animate: Bool

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let animatedScale = animate ? 1.0 : 0.0
            let bmrW = width * bmrFraction * animatedScale
            let activityW = width * activityFraction * animatedScale
            let adjustW = width * adjustFraction * animatedScale
            let markerX = width * targetFraction * animatedScale

            // Static positions for labels (non-animated so they stay put)
            let bmrCenter = width * bmrFraction * 0.5
            let activityCenter = width * bmrFraction + width * activityFraction * 0.5

            // Bar container clips all segments to a single rounded rect
            let barRadius: CGFloat = 8

            ZStack(alignment: .topLeading) {
                // Single bar container with overflow clipping — marker lives inside (matches HTML DOM)
                ZStack(alignment: .leading) {
                    // Track background
                    Rectangle()
                        .fill(FoodiaryDesign.pulseDivider)

                    // BMR segment
                    Rectangle()
                        .fill(FoodiaryDesign.pulsePrimaryDark)
                        .frame(width: max(bmrW, 0))

                    // Activity segment
                    if activityW > 0 {
                        Rectangle()
                            .fill(FoodiaryDesign.pulsePrimary)
                            .frame(width: max(activityW, 0))
                            .offset(x: bmrW)
                    }

                    // Adjustment segment (surplus only)
                    if isSurplus && adjustW > 0 {
                        Rectangle()
                            .fill(FoodiaryDesign.pulseAmber)
                            .frame(width: max(adjustW, 0))
                            .offset(x: bmrW + activityW)
                    }

                    // Target marker — dark line through bar (matches HTML)
                    if markerX > 0 {
                        Rectangle()
                            .fill(FoodiaryDesign.pulseInk)
                            .frame(width: 3, height: 32)
                            .position(x: markerX, y: 16)
                            .allowsHitTesting(false)
                    }
                }
                .frame(width: width, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: barRadius, style: .continuous))

                // In-bar labels (static position, appear after animation)
                if animate && bmrW > 56 {
                    Text("BMR \(bmrLabel)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .position(x: bmrCenter, y: 16)
                        .allowsHitTesting(false)
                }

                if animate && activityW > 36 {
                    Text(activityLabel)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .position(x: activityCenter, y: 16)
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(height: 44)
    }
}

// MARK: - Balance Bar Labels (under the bar)

private struct BalanceBarLabels: View {
    let targetLabel: String
    let maintenanceLabel: String

    var body: some View {
        HStack(spacing: 0) {
            Text("0")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .frame(alignment: .leading)

            Spacer(minLength: 0)

            Text(L10n["label.bmr"])
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(FoodiaryDesign.pulseMuted)

            Spacer(minLength: 0)

            Text("\(L10n["label.target.short"]) \(targetLabel)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(FoodiaryDesign.pulseInk)

            Spacer(minLength: 0)

            Text("\(L10n["label.maintenance.short"]) \(maintenanceLabel)")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(FoodiaryDesign.pulseMuted)
        }
    }
}

// MARK: - Balance Stat Tile

private struct BalanceStatTile: View {
    let value: String
    let label: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Capsule()
                .fill(accentColor)
                .frame(width: 26, height: 4)

            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundColor(FoodiaryDesign.pulseInk)

            Text(label)
                .font(FoodiaryTypography.pulseLabel)
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .textCase(.uppercase)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(FoodiaryDesign.pulseSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
        )
    }
}
