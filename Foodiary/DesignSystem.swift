import SwiftUI

// MARK: - Calorie Ring Design System for Foodiary

enum FoodiaryDesign {
    static let accent = Color(hex: "2563EB")       // Blue
    static let accentLight = Color(hex: "DBEAFE")
    static let secondary = Color(hex: "059669")     // Green
    static let secondaryLight = Color(hex: "D1FAE5")
    static let warning = Color(hex: "D97706")       // Amber
    static let warningLight = Color(hex: "FEF3C7")
    static let background = Color(hex: "F8FAFC")
    static let black = Color(hex: "0F172A")
    static let white = Color.white
    static let muted = Color(hex: "F1F5F9")
    static let mutedFg = Color(hex: "64748B")
    static let border = Color(hex: "CBD5E1")
    static let divider = Color(hex: "F1F5F9")
    
    // Legacy aliases for backward compat during migration
    static let coral = accent
    static let mint = secondary
    static let yellow = warning
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

// MARK: - Typography (Inter for headings, system for body)

enum FoodiaryTypography {
    static let display: Font = .system(size: 34, weight: .bold, design: .default)
    static let title: Font = .system(size: 20, weight: .bold, design: .default)
    static let body: Font = .system(size: 15, design: .default)
    static let bodyBold: Font = .system(size: 15, weight: .semibold, design: .default)
    static let bodySm: Font = .system(size: 13, design: .default)
    static let metric: Font = .system(size: 28, weight: .bold, design: .default)
    static let label: Font = .system(size: 11, weight: .bold, design: .default)
    static let button: Font = .system(size: 15, weight: .bold, design: .default)
    static let badge: Font = .system(size: 11, weight: .bold, design: .default)
    static let segment: Font = .system(size: 12, weight: .bold, design: .default)
}

// MARK: - Soft Shadow Card (replaces HardShadowCard)

/// A card with subtle shadow and thin border — Calorie Ring style
struct SoftCard<Content: View, Background: Shape>: View {
    let bg: Background
    let cornerRadius: CGFloat
    let content: Content
    
    init(bg: Background = RoundedRectangle(cornerRadius: 16), cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.bg = bg
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                bg.fill(FoodiaryDesign.white)
                    .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
            )
            .overlay(
                bg.stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
    }
}

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
}

// MARK: - Button Styles

struct RingButtonStyle: ButtonStyle {
    var bgColor: Color = FoodiaryDesign.accent
    var fgColor: Color = .white
    var cornerRadius: CGFloat = 10
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FoodiaryTypography.button)
            .foregroundColor(fgColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(bgColor)
                    .shadow(color: .black.opacity(configuration.isPressed ? 0.04 : 0.06), radius: 2, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct RingSecondaryButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 10
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FoodiaryTypography.button)
            .foregroundColor(FoodiaryDesign.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(FoodiaryDesign.white)
                    .shadow(color: .black.opacity(configuration.isPressed ? 0.03 : 0.04), radius: 2, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct RingStepperButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(FoodiaryDesign.black)
            .frame(width: 36, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(FoodiaryDesign.white)
                    .shadow(color: .black.opacity(0.04), radius: 1, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct RingIconButtonStyle: ButtonStyle {
    var isDanger: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isDanger ? .white : FoodiaryDesign.black)
            .frame(width: isDanger ? 28 : 32, height: isDanger ? 28 : 32)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDanger ? FoodiaryDesign.black : FoodiaryDesign.white)
                    .shadow(color: .black.opacity(0.04), radius: 1, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(FoodiaryDesign.border, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Tab Bar Modifier

struct RingTabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(FoodiaryDesign.white, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(FoodiaryDesign.white)
                appearance.shadowColor = UIColor(FoodiaryDesign.border)
                appearance.shadowImage = UIImage()
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
    }
}

// MARK: - Nav Bar Modifier

struct RingNavBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(FoodiaryDesign.background)
                appearance.shadowColor = .clear
                appearance.titleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                    .foregroundColor: UIColor(FoodiaryDesign.black)
                ]
                appearance.largeTitleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                    .foregroundColor: UIColor(FoodiaryDesign.black)
                ]
                let navBar = UINavigationBar.appearance()
                navBar.standardAppearance = appearance
                navBar.scrollEdgeAppearance = appearance
                navBar.compactAppearance = appearance
                navBar.tintColor = UIColor(FoodiaryDesign.black)
            }
    }
}

// MARK: - Progress Ring (SVG-style circular progress)

struct RingProgressView: View {
    var progress: Double   // 0...1
    var isOver: Bool
    var size: CGFloat = 172
    var strokeWidth: CGFloat = 14
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(FoodiaryDesign.muted, lineWidth: strokeWidth)
            
            // Progress fill
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    isOver ? FoodiaryDesign.accent : FoodiaryDesign.secondary,
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Macro Bar

struct MacroBar: View {
    var label: String
    var value: Int     // grams
    var maxValue: Int   // for scaling
    var color: Color
    var unit: String = "g"
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(FoodiaryDesign.black)
                .frame(width: 52, alignment: .leading)
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 4)
                    .fill(FoodiaryDesign.muted)
                    .frame(height: 8)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(value) / CGFloat(max(maxValue, 1)))), height: 8)
                    }
            }
            .frame(height: 8)
            Text("\(value)\(unit)")
                .font(.system(size: 13, weight: .bold, design: .default))
                .foregroundColor(FoodiaryDesign.black)
                .frame(width: 36, alignment: .trailing)
        }
    }
}

// MARK: - Progress Bar (kept from original but restyled)

struct RingProgressBar: View {
    var progress: Double
    var isOver: Bool
    
    var body: some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 4)
                .fill(FoodiaryDesign.muted)
                .frame(height: 8)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isOver ? FoodiaryDesign.accent : FoodiaryDesign.secondary)
                        .frame(width: max(0, min(geo.size.width, geo.size.width * progress)), height: 8)
                }
        }
        .frame(height: 8)
    }
}

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
