import SwiftUI

/// Minimal animated launch — just the gauge ring + needle.
///
/// 1. Gauge arc draws clockwise (8-stop gradient matching the app icon).
/// 2. Needle sweeps from left to center-up with spring bounce.
/// 3. Crossfade to the actual app logo.
/// 4. Hold, fade out, transition to the app.
struct SplashView: View {

    var onFinished: () -> Void

    // MARK: - Animation State

    @State private var arcProgress: CGFloat = 0
    @State private var needleAngle: Double = -90
    @State private var gaugeOpacity: Double = 1
    @State private var logoOpacity: Double = 0
    @State private var viewOpacity: Double = 1

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Layout (matches logo size)

    private let gaugeSize: CGFloat = 140
    private let arcWidth: CGFloat = 12
    private var needleHeight: CGFloat { gaugeSize / 2 - arcWidth - 2 }

    // MARK: - Body

    var body: some View {
        ZStack {
            FoodiaryDesign.pulseBackground.ignoresSafeArea()

            // Animated gauge
            gaugeAssembly
                .frame(width: gaugeSize, height: gaugeSize)
                .opacity(gaugeOpacity)

            // Logo
            logoLayer
                .opacity(logoOpacity)
        }
        .opacity(viewOpacity)
        .task {
            if reduceMotion {
                skipAnimation()
            } else {
                await playAnimation()
            }
        }
    }

    // MARK: - Logo Layer

    private var logoLayer: some View {
        VStack(spacing: 12) {
            Image("SplashLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: gaugeSize, height: gaugeSize)
                .cornerRadius(28)
                .shadow(color: .black.opacity(0.12), radius: 16, y: 8)

            Text(L10n["app.name"])
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(FoodiaryDesign.pulseInk)
                .tracking(-0.3)
        }
    }

    // MARK: - Gauge Assembly

    private var gaugeAssembly: some View {
        ZStack {
            trackArc
            gradientArc
            needle
        }
    }

    // MARK: - Track Arc (symmetric semicircle)

    private var trackArc: some View {
        Circle()
            .trim(from: 0.5, to: 1.0)
            .stroke(
                FoodiaryDesign.pulseBorder.opacity(0.30),
                style: StrokeStyle(lineWidth: arcWidth, lineCap: .butt)
            )
    }

    // MARK: - Gradient Arc (matches icon colors, symmetric)

    private var gradientArc: some View {
        Circle()
            .trim(from: 0.5, to: 0.5 + 0.5 * arcProgress)
            .stroke(
                gaugeGradient,
                style: StrokeStyle(lineWidth: arcWidth, lineCap: .butt)
            )
    }

    /// 9-stop gradient matching the app icon.
    /// Symmetric: spans from 9 o'clock (180°) to 3 o'clock (360°).
    private var gaugeGradient: AngularGradient {
        AngularGradient(
            colors: [
                Color(hex: "23C8D3"),  // cyan
                Color(hex: "4BD9B7"),  // aqua green
                Color(hex: "9BE87B"),  // light green
                Color(hex: "D8E84D"),  // yellow-green
                Color(hex: "FFD541"),  // golden yellow
                Color(hex: "FFB23A"),  // orange-yellow
                Color(hex: "FF8A3E"),  // orange
                Color(hex: "FF5E45"),  // red-orange
                Color(hex: "FF3538"),  // red
            ],
            center: .center,
            startAngle: .degrees(180),
            endAngle: .degrees(360)
        )
    }

    // MARK: - Needle (dark navy teardrop, sweeps from left to up)

    private var needle: some View {
        NeedleShape()
            .fill(Color(hex: "1F2739"))
            .frame(width: 7, height: needleHeight)
            .rotationEffect(.degrees(needleAngle), anchor: .bottom)
            .offset(y: -needleHeight / 2)
            .shadow(color: .black.opacity(0.15), radius: 3, y: 1.5)
    }

    // MARK: - Animation Sequence

    private func playAnimation() async {
        // ── Pause ──
        try? await Task.sleep(for: .milliseconds(200))

        // ── Arc draws (1.5 s) ──
        withAnimation(.timingCurve(0.2, 0.0, 0.0, 1.0, duration: 1.5)) {
            arcProgress = 1.0
        }
        try? await Task.sleep(for: .milliseconds(1500))

        // ── Brief pause after arc ──
        try? await Task.sleep(for: .milliseconds(300))

        // ── Needle sweeps (0.6 s spring) ──
        withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) {
            needleAngle = 0
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        try? await Task.sleep(for: .milliseconds(600))

        // ── Pause after needle settles ──
        try? await Task.sleep(for: .milliseconds(800))

        // ── Gauge hides ──
        withAnimation(.easeInOut(duration: 0.5)) {
            gaugeOpacity = 0
        }
        try? await Task.sleep(for: .milliseconds(500))

        // ── Logo fades in (1.2 s) ──
        withAnimation(.easeInOut(duration: 1.2)) {
            logoOpacity = 1
        }
        try? await Task.sleep(for: .milliseconds(1200))

        // ── Logo visible ──
        try? await Task.sleep(for: .milliseconds(700))

        // ── Fade out ──
        withAnimation(.easeOut(duration: 0.4)) {
            viewOpacity = 0
        }
        try? await Task.sleep(for: .milliseconds(400))
        onFinished()
    }

    private func skipAnimation() {
        arcProgress = 1.0
        needleAngle = 0
        gaugeOpacity = 0
        logoOpacity = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            onFinished()
        }
    }
}

// MARK: - Needle Shape

private struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let tip = rect.minY
        let base = rect.maxY
        let hw = rect.width / 2

        var path = Path()
        path.move(to: CGPoint(x: cx, y: tip))
        path.addQuadCurve(
            to: CGPoint(x: cx, y: base),
            control: CGPoint(x: cx + hw, y: rect.midY + rect.height * 0.08)
        )
        path.addQuadCurve(
            to: CGPoint(x: cx, y: tip),
            control: CGPoint(x: cx - hw, y: rect.midY + rect.height * 0.08)
        )
        return path
    }
}
