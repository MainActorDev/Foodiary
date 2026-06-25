import SwiftUI

// MARK: - Legacy compatibility aliases (deprecated, use Ring* variants)

typealias NBButtonStyle = RingButtonStyle
typealias NBSecondaryButtonStyle = RingSecondaryButtonStyle
typealias NBStepperButtonStyle = RingStepperButtonStyle
typealias NBIconButtonStyle = RingIconButtonStyle
typealias NBProgressBar = RingProgressBar
typealias NBNavBarModifier = RingNavBarModifier
typealias NBTabBarModifier = RingTabBarModifier
typealias HardShadowCard = SoftCard

// Backward-compatible nb modifier wrappers
extension View {
    func nbCard(cornerRadius: CGFloat = 20) -> some View {
        self.ringCard(cornerRadius: cornerRadius)
    }
    func nbCardCompact(cornerRadius: CGFloat = 16) -> some View {
        self.ringCardCompact(cornerRadius: cornerRadius)
    }
    func nbCardColored(bg: Color, cornerRadius: CGFloat = 8) -> some View {
        self.ringCardColored(bg: bg, cornerRadius: cornerRadius)
    }
    func nbField(cornerRadius: CGFloat = 12) -> some View {
        self.ringField(cornerRadius: cornerRadius)
    }
    func nbSegment(isActive: Bool) -> some View {
        self.ringSegment(isActive: isActive)
    }
    func nbBadge(bg: Color) -> some View {
        self.ringBadge(bg: bg)
    }
}
