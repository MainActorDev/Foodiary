import SwiftUI

// MARK: - Pulse v2 / Calorie Ring Design System for Foodiary

enum FoodiaryDesign {
    // Pulse v2 tokens — clean, modern planning cockpit
    static let pulseBackground = Color(hex: "F6F7FF")
    static let pulseBackgroundAlt = Color(hex: "F8FAFF")
    static let pulseSurface = Color.white
    static let pulseSurfaceSoft = Color(hex: "EEF0FF")
    static let pulseSurfaceMint = Color(hex: "E6FBF3")
    static let pulsePrimary = Color(hex: "7C3AED")
    static let pulsePrimaryLight = Color(hex: "EDE9FE")
    static let pulsePrimaryDark = Color(hex: "15142A")
    static let pulseMint = Color(hex: "10B981")
    static let pulseMintLight = Color(hex: "D1FAE5")
    static let pulseCyan = Color(hex: "38BDF8")
    static let pulseCyanLight = Color(hex: "E0F6FF")
    static let pulseAmber = Color(hex: "F59E0B")
    static let pulseAmberLight = Color(hex: "FEF3C7")
    static let pulseInk = Color(hex: "15142A")
    static let pulseMuted = Color(hex: "6B6880")
    static let pulseBorder = Color(hex: "C8C6D0")
    static let pulseDivider = Color(hex: "E8E6F0")
    static let pulseDanger = Color(hex: "EF4444")
    static let pulseDangerLight = Color(hex: "FEE2E2")
    
    // Day pill state colors (from prototype)
    static let pulseDayEmpty = Color(hex: "FFF7ED")
    static let pulseDayEmptyFg = Color(hex: "B45309")
    static let pulseDayFuture = Color(hex: "E6FBF3")
    static let pulseDayFutureFg = Color(hex: "047857")
    static let pulseDayActiveFg = Color.white
    
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
    
    static func pulseMealTint(for mealType: Meal.MealType) -> Color {
        switch mealType {
        case .breakfast: return Color(hex: "FFF4D8")
        case .lunch: return pulseMintLight
        case .snack: return Color(hex: "FCE7F3")
        case .dinner: return pulsePrimaryLight
        }
    }
    
    static func pulseMealAccent(for mealType: Meal.MealType) -> Color {
        switch mealType {
        case .breakfast: return pulseAmber
        case .lunch: return pulseMint
        case .snack: return Color(hex: "EC4899")
        case .dinner: return pulsePrimary
        }
    }
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
    
    // Pulse v2 typography
    static let pulseDisplay: Font = .system(size: 38, weight: .heavy, design: .rounded).monospacedDigit()
    static let pulseMetric: Font = .system(size: 30, weight: .heavy, design: .rounded).monospacedDigit()
    static let pulseTitle: Font = .system(size: 22, weight: .bold, design: .rounded)
    static let pulseHeadline: Font = .system(size: 17, weight: .bold, design: .rounded)
    static let pulseBody: Font = .system(size: 15, weight: .regular, design: .default)
    static let pulseBodyBold: Font = .system(size: 15, weight: .semibold, design: .default)
    static let pulseCaption: Font = .system(size: 12, weight: .medium, design: .default)
    static let pulseLabel: Font = .system(size: 11, weight: .bold, design: .default)
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

    // MARK: Pulse v2 modifiers

    func pulseCard(cornerRadius: CGFloat = 22, padding: CGFloat = 18) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(FoodiaryDesign.pulseSurface)
                    .shadow(color: FoodiaryDesign.pulsePrimaryDark.opacity(0.055), radius: 30, x: 0, y: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
            )
    }

    func pulseHeroCard(cornerRadius: CGFloat = 28, padding: CGFloat = 22) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [FoodiaryDesign.pulsePrimaryDark, Color(hex: "2D2152")],
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

    func pulseSectionLabel() -> some View {
        self
            .font(FoodiaryTypography.pulseLabel)
            .foregroundColor(FoodiaryDesign.pulseMuted)
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

// MARK: - Pulse v2 Button Styles

struct PulsePrimaryButtonStyle: ButtonStyle {
    var bgColor: Color = FoodiaryDesign.pulsePrimary
    var fgColor: Color = .white
    var cornerRadius: CGFloat = 16
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FoodiaryTypography.button)
            .foregroundColor(fgColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(bgColor)
                    .shadow(color: bgColor.opacity(configuration.isPressed ? 0.12 : 0.24), radius: 12, x: 0, y: configuration.isPressed ? 4 : 8)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct PulseSecondaryButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 16
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FoodiaryTypography.button)
            .foregroundColor(FoodiaryDesign.pulseInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(FoodiaryDesign.pulseSurface)
                    .shadow(color: FoodiaryDesign.pulsePrimaryDark.opacity(configuration.isPressed ? 0.03 : 0.06), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct PulseIconButtonStyle: ButtonStyle {
    var bgColor: Color = FoodiaryDesign.pulseSurface
    var fgColor: Color = FoodiaryDesign.pulseInk
    var size: CGFloat = 40
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(fgColor)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: size / 2.5, style: .continuous)
                    .fill(bgColor)
                    .shadow(color: FoodiaryDesign.pulsePrimaryDark.opacity(configuration.isPressed ? 0.03 : 0.06), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: size / 2.5, style: .continuous)
                    .stroke(FoodiaryDesign.pulseBorder, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Tab Bar Modifier

struct RingTabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(FoodiaryDesign.pulseBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(FoodiaryDesign.pulseBackground)
                appearance.shadowColor = UIColor(FoodiaryDesign.pulseBorder)
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
                appearance.configureWithTransparentBackground()
                appearance.shadowColor = .clear
                appearance.titleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                    .foregroundColor: UIColor(FoodiaryDesign.pulseInk)
                ]
                appearance.largeTitleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                    .foregroundColor: UIColor(FoodiaryDesign.pulseInk)
                ]
                let navBar = UINavigationBar.appearance()
                navBar.standardAppearance = appearance
                navBar.scrollEdgeAppearance = appearance
                navBar.compactAppearance = appearance
                navBar.tintColor = UIColor(FoodiaryDesign.pulseInk)
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

// MARK: - Pulse v2 Data Components

struct PulseBudgetSegment: Identifiable {
    let id: String
    let value: Double
    let color: Color
    
    init(id: String, value: Double, color: Color) {
        self.id = id
        self.value = value
        self.color = color
    }
}

struct PulseSegmentedBudgetBar: View {
    var segments: [PulseBudgetSegment]
    var trackColor: Color = FoodiaryDesign.pulseDivider
    var height: CGFloat = 12
    
    private var positiveSegments: [PulseBudgetSegment] {
        segments.filter { $0.value > 0 }
    }
    
    private var total: Double {
        max(positiveSegments.reduce(0) { $0 + $1.value }, 1)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(trackColor)
                ForEach(Array(positiveSegments.enumerated()), id: \.element.id) { index, segment in
                    Capsule()
                        .fill(segment.color)
                        .frame(width: width(for: segment, in: geo.size.width), height: height)
                        .offset(x: offset(before: index, in: geo.size.width))
                }
            }
        }
        .frame(height: height)
        .clipShape(Capsule())
    }
    
    private func width(for segment: PulseBudgetSegment, in totalWidth: CGFloat) -> CGFloat {
        totalWidth * CGFloat(segment.value / total)
    }
    
    private func offset(before index: Int, in totalWidth: CGFloat) -> CGFloat {
        let prefix = positiveSegments.prefix(index).reduce(0) { $0 + $1.value }
        return totalWidth * CGFloat(prefix / total)
    }
}

struct PulseBudgetHero: View {
    var eyebrow: String
    var value: String
    var unit: String
    var subtitle: String
    var progress: Double
    var isOver: Bool
    var actionTitle: String?
    var action: (() -> Void)?
    
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(eyebrow)
                .font(FoodiaryTypography.pulseLabel)
                .foregroundColor(.white.opacity(0.68))
                .textCase(.uppercase)
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(value)
                    .font(FoodiaryTypography.pulseDisplay)
                    .foregroundColor(.white)
                Text(unit)
                    .font(FoodiaryTypography.pulseHeadline)
                    .foregroundColor(.white.opacity(0.72))
            }
            
            Text(subtitle)
                .font(FoodiaryTypography.pulseBody)
                .foregroundColor(.white.opacity(0.78))
            
            GeometryReader { geo in
                Capsule()
                    .fill(.white.opacity(0.16))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(isOver ? FoodiaryDesign.pulseAmber : FoodiaryDesign.pulseMint)
                            .frame(width: max(8, geo.size.width * CGFloat(clampedProgress)))
                    }
            }
            .frame(height: 12)
            .clipShape(Capsule())
            
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(PulsePrimaryButtonStyle(bgColor: .white, fgColor: FoodiaryDesign.pulsePrimaryDark))
            }
        }
        .pulseHeroCard()
    }
}

struct PulseMetricTile: View {
    var value: String
    var label: String
    var caption: String? = nil
    var accent: Color = FoodiaryDesign.pulsePrimary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Capsule()
                .fill(accent)
                .frame(width: 26, height: 4)
            Text(value)
                .font(FoodiaryTypography.pulseMetric)
                .foregroundColor(FoodiaryDesign.pulseInk)
            Text(label)
                .font(FoodiaryTypography.pulseLabel)
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .textCase(.uppercase)
            if let caption {
                Text(caption)
                    .font(FoodiaryTypography.pulseCaption)
                    .foregroundColor(FoodiaryDesign.pulseMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .pulseCard(cornerRadius: 20, padding: 14)
    }
}

struct PulseMacroChip: View {
    var label: String
    var value: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 9, height: 9)
            Text(label)
                .font(FoodiaryTypography.pulseCaption)
                .foregroundColor(FoodiaryDesign.pulseMuted)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(FoodiaryDesign.pulseInk)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(FoodiaryDesign.pulseSurfaceSoft))
    }
}

struct PulseMealIconTile: View {
    var mealType: Meal.MealType
    var showsLabel: Bool = false
    
    private var emoji: String {
        switch mealType {
        case .breakfast: return "🍳"
        case .lunch: return "🍱"
        case .snack: return "🍌"
        case .dinner: return "🍽️"
        }
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(emoji)
                .font(.system(size: 26))
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(FoodiaryDesign.pulseMealTint(for: mealType))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(FoodiaryDesign.pulseMealAccent(for: mealType).opacity(0.24), lineWidth: 1)
                )
            if showsLabel {
                Text(mealType.localizedDisplayName)
                    .font(FoodiaryTypography.pulseLabel)
                    .foregroundColor(FoodiaryDesign.pulseMuted)
                    .lineLimit(1)
            }
        }
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
