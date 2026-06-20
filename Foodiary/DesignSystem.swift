import SwiftUI

// MARK: - Neubrutalist Design System for Foodiary

enum FoodiaryDesign {
    static let coral = Color(hex: "FF6B4A")
    static let coralDark = Color(hex: "E55A3A")
    static let mint = Color(hex: "2DD4BF")
    static let yellow = Color(hex: "FFD60A")
    static let background = Color(hex: "FAFAF5")
    static let black = Color(hex: "1A1A1A")
    static let white = Color.white
    static let muted = Color(hex: "F5F2ED")
    static let mutedFg = Color(hex: "6B6560")
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

// MARK: - Typography

enum FoodiaryTypography {
    static let display: Font = .system(size: 40, weight: .bold, design: .rounded)
    static let title: Font = .system(size: 22, weight: .bold, design: .rounded)
    static let body: Font = .system(size: 15, weight: .regular, design: .default)
    static let bodyBold: Font = .system(size: 15, weight: .semibold, design: .default)
    static let bodySm: Font = .system(size: 13, weight: .regular, design: .default)
    static let metric: Font = .system(size: 32, weight: .bold, design: .rounded)
    static let label: Font = .system(size: 11, weight: .bold, design: .rounded)
    static let button: Font = .system(size: 15, weight: .bold, design: .rounded)
    static let badge: Font = .system(size: 11, weight: .bold, design: .rounded)
    static let segment: Font = .system(size: 12, weight: .bold, design: .rounded)
}

// MARK: - Hard Shadow Builder (CSS-style box-shadow: 4px 4px 0 #000)

/// Renders a shape with a true hard offset shadow — black shape behind, offset by (dx, dy).
/// Matches CSS `box-shadow: <dx> <dy> 0 #000` with a solid border.
struct HardShadowCard<Content: View, Background: Shape>: View {
    let bg: Background
    let shadowOffset: CGSize
    let borderWidth: CGFloat
    let content: Content
    
    init(
        bg: Background,
        shadowOffset: CGSize = CGSize(width: 4, height: 4),
        borderWidth: CGFloat = 3,
        @ViewBuilder content: () -> Content
    ) {
        self.bg = bg
        self.shadowOffset = shadowOffset
        self.borderWidth = borderWidth
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                ZStack {
                    bg.fill(Color.black)
                        .offset(shadowOffset)
                    bg.fill(FoodiaryDesign.white)
                    bg.stroke(FoodiaryDesign.black, lineWidth: borderWidth)
                }
            )
    }
}

// MARK: - View Modifiers

extension View {
    /// Applies a neubrutalist card style with hard offset shadow + thick border
    func nbCard(cornerRadius: CGFloat = 20, shadowOffset: CGSize = CGSize(width: 4, height: 4), borderWidth: CGFloat = 3, padding: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .padding(.trailing, shadowOffset.width)
            .padding(.bottom, shadowOffset.height)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(FoodiaryDesign.black)
                        .offset(shadowOffset)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(FoodiaryDesign.white)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(FoodiaryDesign.black, lineWidth: borderWidth)
                }
            )
            .padding(.trailing, -shadowOffset.width)
            .padding(.bottom, -shadowOffset.height)
    }
    
    /// Compact card with smaller shadow
    func nbCardCompact(cornerRadius: CGFloat = 16, shadowOffset: CGSize = CGSize(width: 3, height: 3), borderWidth: CGFloat = 3, padding: CGFloat = 14) -> some View {
        self
            .padding(padding)
            .padding(.trailing, shadowOffset.width)
            .padding(.bottom, shadowOffset.height)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(FoodiaryDesign.black)
                        .offset(shadowOffset)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(FoodiaryDesign.white)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(FoodiaryDesign.black, lineWidth: borderWidth)
                }
            )
            .padding(.trailing, -shadowOffset.width)
            .padding(.bottom, -shadowOffset.height)
    }
    
    /// Card with colored background (for meal icons, badges)
    func nbCardColored(bg: Color, cornerRadius: CGFloat = 8, shadowOffset: CGSize = CGSize(width: 2, height: 2), borderWidth: CGFloat = 2, padding: CGFloat = 10) -> some View {
        self
            .padding(padding)
            .padding(.trailing, shadowOffset.width)
            .padding(.bottom, shadowOffset.height)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(FoodiaryDesign.black)
                        .offset(shadowOffset)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(bg)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(FoodiaryDesign.black, lineWidth: borderWidth)
                }
            )
            .padding(.trailing, -shadowOffset.width)
            .padding(.bottom, -shadowOffset.height)
    }
    
    /// Input field style
    func nbField(cornerRadius: CGFloat = 12) -> some View {
        self
            .padding(12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(FoodiaryDesign.white)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(FoodiaryDesign.black, lineWidth: 3)
                }
            )
    }
    
    /// Segmented control option
    func nbSegment(isActive: Bool) -> some View {
        self
            .font(FoodiaryTypography.segment)
            .foregroundColor(isActive ? FoodiaryDesign.black : FoodiaryDesign.mutedFg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isActive {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(FoodiaryDesign.black)
                            .offset(x: 2, y: 2)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(FoodiaryDesign.white)
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(FoodiaryDesign.black, lineWidth: 2)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.clear)
                    }
                }
            )
    }
    
    /// Pill badge
    func nbBadge(bg: Color) -> some View {
        self
            .font(FoodiaryTypography.badge)
            .foregroundColor(bg == Color(hex: "D1FAE5") ? Color(hex: "065F46") :
                            bg == Color(hex: "FEE2E2") ? Color(hex: "991B1B") :
                            bg == Color(hex: "FEF9C3") ? Color(hex: "854D0E") : FoodiaryDesign.mutedFg)
            .padding(.horizontal, 14)
            .padding(.vertical, 5)
            .padding(.trailing, 2)
            .padding(.bottom, 2)
            .background(
                ZStack {
                    Capsule()
                        .fill(FoodiaryDesign.black)
                        .offset(x: 2, y: 2)
                    Capsule()
                        .fill(bg)
                    Capsule()
                        .stroke(FoodiaryDesign.black, lineWidth: 2)
                }
            )
            .padding(.trailing, -2)
            .padding(.bottom, -2)
    }
    
    /// Section label (ALL CAPS)
    func sectionLabel() -> some View {
        self
            .font(FoodiaryTypography.label)
            .foregroundColor(FoodiaryDesign.black)
            .textCase(.uppercase)
    }
}

// MARK: - Neubrutalist Button Style (with hard shadow)

struct NBButtonStyle: ButtonStyle {
    var bgColor: Color = FoodiaryDesign.coral
    var fgColor: Color = .white
    var cornerRadius: CGFloat = 12
    var borderWidth: CGFloat = 3
    var shadowOffset: CGSize = CGSize(width: 4, height: 4)
    
    func makeBody(configuration: Configuration) -> some View {
        let offset = configuration.isPressed ? CGSize(width: 2, height: 2) : shadowOffset
        
        return configuration.label
            .font(FoodiaryTypography.button)
            .foregroundColor(fgColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(FoodiaryDesign.black)
                        .offset(offset)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(bgColor)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(FoodiaryDesign.black, lineWidth: borderWidth)
                }
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct NBSecondaryButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 12
    var borderWidth: CGFloat = 3
    var shadowOffset: CGSize = CGSize(width: 4, height: 4)
    
    func makeBody(configuration: Configuration) -> some View {
        let offset = configuration.isPressed ? CGSize(width: 2, height: 2) : shadowOffset
        
        return configuration.label
            .font(FoodiaryTypography.button)
            .foregroundColor(FoodiaryDesign.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(FoodiaryDesign.black)
                        .offset(offset)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(FoodiaryDesign.white)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(FoodiaryDesign.black, lineWidth: borderWidth)
                }
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct NBStepperButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let offset = configuration.isPressed ? CGSize(width: 1, height: 1) : CGSize(width: 2, height: 2)
        return configuration.label
            .foregroundColor(FoodiaryDesign.black)
            .frame(width: 36, height: 36)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(FoodiaryDesign.black)
                        .offset(offset)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(FoodiaryDesign.white)
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(FoodiaryDesign.black, lineWidth: 2)
                }
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct NBIconButtonStyle: ButtonStyle {
    var isDanger: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        let offset = configuration.isPressed ? CGSize(width: 1, height: 1) : CGSize(width: 2, height: 2)
        return configuration.label
            .foregroundColor(isDanger ? .white : FoodiaryDesign.black)
            .frame(width: isDanger ? 28 : 32, height: isDanger ? 28 : 32)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(FoodiaryDesign.black)
                        .offset(offset)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isDanger ? FoodiaryDesign.black : FoodiaryDesign.white)
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(FoodiaryDesign.black, lineWidth: 2)
                }
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Neubrutalist Tab Bar Modifier
struct NBTabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(FoodiaryDesign.white, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(FoodiaryDesign.white)
                appearance.shadowColor = UIColor(FoodiaryDesign.black)
                appearance.shadowImage = UIImage()
                // Add a 3px top border
                let tabBar = UITabBar.appearance()
                tabBar.standardAppearance = appearance
                tabBar.scrollEdgeAppearance = appearance
                tabBar.layer.borderWidth = 0
                tabBar.clipsToBounds = true
            }
    }
}

// MARK: - Neubrutalist Navigation Bar
struct NBNavBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(FoodiaryDesign.background)
                appearance.shadowColor = .clear
                appearance.titleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold, width: .standard),
                    .foregroundColor: UIColor(FoodiaryDesign.black)
                ]
                appearance.largeTitleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 28, weight: .bold, width: .standard),
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

// MARK: - Progress Bar
struct NBProgressBar: View {
    var progress: Double // 0...1
    var isOver: Bool
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(FoodiaryDesign.muted)
                    .frame(height: 12)
                RoundedRectangle(cornerRadius: 6)
                    .stroke(FoodiaryDesign.black, lineWidth: 2)
                    .frame(height: 12)
                RoundedRectangle(cornerRadius: 6)
                    .fill(isOver ? FoodiaryDesign.coral : FoodiaryDesign.mint)
                    .frame(width: max(0, min(geo.size.width, geo.size.width * progress)), height: 12)
            }
        }
        .frame(height: 12)
    }
}
