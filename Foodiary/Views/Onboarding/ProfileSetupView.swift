import SwiftUI

struct ProfileSetupView: View {
    @Binding var age: Int
    @Binding var sex: UserProfile.Sex
    @Binding var heightCm: Double
    @Binding var weightKg: Double
    var onBack: () -> Void
    var onContinue: () -> Void

    @State private var localAge: Int
    @State private var localHeight: Int
    @State private var localWeight: Int
    @State private var localSex: UserProfile.Sex

    @State private var activeField: Field = .age

    enum Field: Int, CaseIterable {
        case age, height, weight, sex
        var label: String { ["Age", "Height", "Weight", "Sex"][rawValue] }
        var unit: String { ["years", "cm", "kg", ""][rawValue] }
        var range: ClosedRange<Int> {
            switch self {
            case .age: return 1...100
            case .height: return 120...220
            case .weight: return 30...150
            case .sex: return 0...1
            }
        }
        var next: Field? { Field(rawValue: rawValue + 1) }
    }

    init(age: Binding<Int>, sex: Binding<UserProfile.Sex>, heightCm: Binding<Double>, weightKg: Binding<Double>, onBack: @escaping () -> Void, onContinue: @escaping () -> Void) {
        self._age = age
        self._sex = sex
        self._heightCm = heightCm
        self._weightKg = weightKg
        self.onBack = onBack
        self.onContinue = onContinue
        _localAge = State(initialValue: age.wrappedValue > 0 ? age.wrappedValue : 25)
        _localHeight = State(initialValue: heightCm.wrappedValue > 0 ? Int(heightCm.wrappedValue) : 170)
        _localWeight = State(initialValue: weightKg.wrappedValue > 0 ? Int(weightKg.wrappedValue) : 70)
        _localSex = State(initialValue: sex.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(PulseIconButtonStyle(fgColor: FoodiaryDesign.pulseMuted))

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // Progress bar
            HStack(spacing: 6) {
                ForEach(Field.allCases, id: \.self) { field in
                    Capsule()
                        .fill(field.rawValue <= activeField.rawValue ? FoodiaryDesign.pulsePrimary : FoodiaryDesign.pulseSurfaceSoft)
                        .frame(height: 4)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activeField)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()

            // Main display
            Group {
                switch activeField {
                case .sex: sexDisplay
                default: numberDisplay
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .id(activeField)

            Spacer()

            // Ruler
            if activeField != .sex {
                rulerView
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Navigation buttons
            HStack(spacing: 12) {
                if activeField.rawValue > 0 {
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            activeField = Field(rawValue: activeField.rawValue - 1) ?? .age
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(FoodiaryDesign.pulseInk)
                            .frame(width: 52, height: 52)
                            .background(Circle().fill(FoodiaryDesign.pulseSurfaceSoft))
                    }
                }

                Button(action: nextTapped) {
                    HStack(spacing: 8) {
                        Text(activeField == .sex ? L10n["action.continue"] : "Next")
                        Image(systemName: activeField == .sex ? "checkmark" : "arrow.right")
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
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Next

    private func nextTapped() {
        if let nextField = activeField.next {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                activeField = nextField
            }
        } else {
            age = localAge
            heightCm = Double(localHeight)
            weightKg = Double(localWeight)
            sex = localSex
            onContinue()
        }
    }

    // MARK: - Number display

    private var numberDisplay: some View {
        let value = currentValue

        return VStack(spacing: 12) {
            Text(activeField.label.uppercased())
                .font(.system(size: 14, weight: .black))
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .tracking(3)

            Text("\(value)")
                .font(.system(size: 96, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundColor(FoodiaryDesign.pulsePrimary)
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.08), value: value)

            Text(activeField.unit.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .tracking(3)
        }
    }

    private var currentValue: Int {
        switch activeField {
        case .age: return localAge
        case .height: return localHeight
        case .weight: return localWeight
        case .sex: return 0
        }
    }

    private func updateValue(_ newValue: Int) {
        switch activeField {
        case .age: localAge = newValue
        case .height: localHeight = newValue
        case .weight: localWeight = newValue
        case .sex: break
        }
    }

    // MARK: - Sex display

    private var sexDisplay: some View {
        VStack(spacing: 16) {
            Text("SEX")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .tracking(3)
                .padding(.bottom, 4)

            ForEach(UserProfile.Sex.allCases, id: \.self) { option in
                Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { localSex = option } }) {
                    HStack {
                        Text(option == .female ? "Female" : "Male")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(localSex == option ? .white : FoodiaryDesign.pulseInk)
                        Spacer()
                        if localSex == option {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(localSex == option ? FoodiaryDesign.pulsePrimary : Color.white.opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(localSex == option ? Color.clear : Color(hex: "15142A").opacity(0.06), lineWidth: 1)
                    )
                    .scaleEffect(localSex == option ? 1.02 : 1.0)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Ruler (scrolling ruler, fixed center indicator)

    @State private var activeDrag: CGFloat = 0

    private let tickSpacing: CGFloat = 36

    private var rulerView: some View {
        let range = activeField.range
        let value = currentValue

        return GeometryReader { geo in
            let width = geo.size.width
            let tickCount = range.upperBound - range.lowerBound

            // Offset so the CENTER of tick `value` sits exactly at screen center
            // Tick i center = i * tickSpacing + tickSpacing/2 within the HStack
            let baseOffset = width / 2 - (CGFloat(value - range.lowerBound) * tickSpacing + tickSpacing / 2)
            let liveOffset = baseOffset + activeDrag

            ZStack {
                // Ruler background bar
                RoundedRectangle(cornerRadius: 8)
                    .fill(FoodiaryDesign.pulseSurfaceSoft)
                    .frame(height: 44)

                // Tick marks strip
                HStack(spacing: 0) {
                    ForEach(0...tickCount, id: \.self) { i in
                        let tickValue = range.lowerBound + i
                        let isMajor = i % 10 == 0 || i == tickCount
                        let isMid = i % 5 == 0
                        let tickHeight: CGFloat = isMajor ? 28 : (isMid ? 20 : 10)

                        VStack(spacing: 4) {
                            if isMajor {
                                Text("\(tickValue)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(FoodiaryDesign.pulseInk.opacity(0.5))
                            } else {
                                Color.clear.frame(height: 12)
                            }
                            Rectangle()
                                .fill(FoodiaryDesign.pulseInk.opacity(isMajor ? 0.35 : (isMid ? 0.2 : 0.08)))
                                .frame(width: isMajor ? 2 : 1, height: tickHeight)
                        }
                        .frame(width: tickSpacing, height: 44)
                    }
                }
                .offset(x: liveOffset)
                .frame(width: width, alignment: .leading)
                .clipped()

                // Fixed center indicator
                Rectangle()
                    .fill(FoodiaryDesign.pulsePrimary)
                    .frame(width: 4, height: 56)
                    .shadow(color: FoodiaryDesign.pulsePrimary.opacity(0.3), radius: 4)

                // Fade edges
                HStack {
                    LinearGradient(colors: [FoodiaryDesign.pulseBackground, .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 60)
                    Spacer()
                    LinearGradient(colors: [.clear, FoodiaryDesign.pulseBackground], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 60)
                }
                .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { g in
                        activeDrag = g.translation.width
                    }
                    .onEnded { g in
                        let ticksDragged = -g.translation.width / tickSpacing
                        let snappedTicks = round(ticksDragged)
                        let newValue = max(range.lowerBound, min(range.upperBound, value + Int(snappedTicks)))
                        updateValue(newValue)
                        activeDrag = 0
                    }
            )
        }
        .frame(height: 90)
    }
}

// MARK: - Triangle shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
