import SwiftUI

// MARK: - View Modifiers

extension View {
    /// Standard card with soft shadow + thin border
    func ringCard(cornerRadius: CGFloat = 16) -> some View {
        self
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(FoodiaryDesign.white)
                    .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
    }

    /// Compact card
    func ringCardCompact(cornerRadius: CGFloat = 14) -> some View {
        self
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(FoodiaryDesign.white)
                    .shadow(color: .black.opacity(0.03), radius: 1, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
    }

    /// Colored card for meal icons
    func ringCardColored(bg: Color, cornerRadius: CGFloat = 8) -> some View {
        self
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
    }

    /// Input field
    func ringField(cornerRadius: CGFloat = 10) -> some View {
        self
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(FoodiaryDesign.white)
                    .shadow(color: .black.opacity(0.03), radius: 1, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
    }

    /// Segmented control option
    func ringSegment(isActive: Bool) -> some View {
        self
            .font(FoodiaryTypography.segment)
            .foregroundColor(isActive ? FoodiaryDesign.black : FoodiaryDesign.mutedFg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? FoodiaryDesign.white : Color.clear)
                    .shadow(color: isActive ? .black.opacity(0.06) : .clear, radius: 2, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? FoodiaryDesign.border : Color.clear, lineWidth: 1.5)
            )
    }

    /// Pill badge
    func ringBadge(bg: Color) -> some View {
        self
            .font(FoodiaryTypography.badge)
            .foregroundColor(bg == FoodiaryDesign.secondaryLight ? Color(hex: "065F46") :
                            bg == Color(hex: "FEE2E2") ? Color(hex: "991B1B") :
                            bg == FoodiaryDesign.warningLight ? Color(hex: "92400E") : FoodiaryDesign.mutedFg)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(bg))
            .overlay(Capsule().stroke(FoodiaryDesign.border, lineWidth: 1))
    }

    /// Section label (ALL CAPS)
    func sectionLabel() -> some View {
        self
            .font(FoodiaryTypography.label)
            .foregroundColor(FoodiaryDesign.black)
            .textCase(.uppercase)
    }

    // MARK: Pulse v2 modifiers

    func pulseCard(
        cornerRadius: CGFloat = 22,
        padding: CGFloat = 18,
        shadowRadius: CGFloat = 30,
        shadowY: CGFloat = 14,
        strokeOpacity: Double = 0.10
    ) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(FoodiaryDesign.pulseSurface)
                    .shadow(color: FoodiaryDesign.pulseCardShadow, radius: shadowRadius, x: 0, y: shadowY)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(FoodiaryDesign.pulseInk.opacity(strokeOpacity), lineWidth: 1)
            )
    }

    func pulseHeroCard(cornerRadius: CGFloat = 28, padding: CGFloat = 22) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [FoodiaryDesign.pulsePrimaryDark, Color(hex: "0A4070")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: FoodiaryDesign.pulsePrimary.opacity(0.22), radius: 24, x: 0, y: 14)
            )
    }

    func pulseSoftPanel(cornerRadius: CGFloat = 18, padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(FoodiaryDesign.pulseSurfaceSoft)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(FoodiaryDesign.pulseBorder.opacity(0.8), lineWidth: 1)
            )
    }

    func pulseField(cornerRadius: CGFloat = 16) -> some View {
        self
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(FoodiaryDesign.pulseSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
            )
    }

    func pulseBadge(bg: Color = FoodiaryDesign.pulseSurfaceSoft, fg: Color = FoodiaryDesign.pulseInk) -> some View {
        self
            .font(FoodiaryTypography.pulseLabel)
            .foregroundColor(fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(bg))
    }

    func pulseSectionLabel(size: CGFloat = 11, weight: Font.Weight = .heavy) -> some View {
        self
            .font(.system(size: size, weight: weight))
            .foregroundColor(FoodiaryDesign.pulseMuted)
            .tracking(0.6)
            .textCase(.uppercase)
    }

    /// Hides system back button and installs a custom-styled one.
    /// Handles both `.navigationBarBackButtonHidden` and the toolbar item.
    func pulseBackButton(
        icon: String = "arrow.left",
        dismiss: DismissAction,
        hideTabBar: Bool = false
    ) -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .toolbar(hideTabBar ? .hidden : .automatic, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(PulseIconButtonStyle(size: 36))
                }
            }
    }
}
