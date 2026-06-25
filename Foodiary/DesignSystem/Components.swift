import SwiftUI

// MARK: - Soft Shadow Card

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

// MARK: - Progress Ring (SVG-style circular progress)

struct RingProgressView: View {
    var progress: Double   // 0...1
    var isOver: Bool
    var size: CGFloat = 172
    var strokeWidth: CGFloat = 14

    var body: some View {
        ZStack {
            Circle()
                .stroke(FoodiaryDesign.muted, lineWidth: strokeWidth)
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
    var value: Int
    var maxValue: Int
    var color: Color
    var unit: String = "g"

    var body: some View {
        HStack(spacing: 10) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label).font(.system(size: 13, weight: .semibold)).foregroundColor(FoodiaryDesign.black).frame(width: 52, alignment: .leading)
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 4)
                    .fill(FoodiaryDesign.muted).frame(height: 8)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(value) / CGFloat(max(maxValue, 1)))), height: 8)
                    }
            }
            .frame(height: 8)
            Text("\(value)\(unit)").font(.system(size: 13, weight: .bold, design: .default)).foregroundColor(FoodiaryDesign.black).frame(width: 36, alignment: .trailing)
        }
    }
}

// MARK: - Progress Bar

struct RingProgressBar: View {
    var progress: Double
    var isOver: Bool

    var body: some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 4)
                .fill(FoodiaryDesign.muted).frame(height: 8)
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

    private var positiveSegments: [PulseBudgetSegment] { segments.filter { $0.value > 0 } }
    private var total: Double { max(positiveSegments.reduce(0) { $0 + $1.value }, 1) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(trackColor)
                ForEach(Array(positiveSegments.enumerated()), id: \.element.id) { index, segment in
                    Capsule().fill(segment.color)
                        .frame(width: width(for: segment, in: geo.size.width), height: height)
                        .offset(x: offset(before: index, in: geo.size.width))
                }
            }
        }
        .frame(height: height).clipShape(Capsule())
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

    private var clampedProgress: Double { min(max(progress, 0), 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(eyebrow).font(FoodiaryTypography.pulseLabel).foregroundColor(.white.opacity(0.68)).textCase(.uppercase)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(value).font(FoodiaryTypography.pulseDisplay).foregroundColor(.white)
                Text(unit).font(FoodiaryTypography.pulseHeadline).foregroundColor(.white.opacity(0.72))
            }
            Text(subtitle).font(FoodiaryTypography.pulseBody).foregroundColor(.white.opacity(0.78))
            GeometryReader { geo in
                Capsule().fill(.white.opacity(0.16))
                    .overlay(alignment: .leading) {
                        Capsule().fill(isOver ? FoodiaryDesign.pulseAmber : FoodiaryDesign.pulseMint)
                            .frame(width: max(8, geo.size.width * CGFloat(clampedProgress)))
                    }
            }
            .frame(height: 12).clipShape(Capsule())
            if let actionTitle, let action {
                Button(action: action) { Text(actionTitle) }
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
            Capsule().fill(accent).frame(width: 26, height: 4)
            Text(value).font(FoodiaryTypography.pulseMetric).foregroundColor(FoodiaryDesign.pulseInk)
            Text(label).font(FoodiaryTypography.pulseLabel).foregroundColor(FoodiaryDesign.pulseMuted).textCase(.uppercase)
            if let caption {
                Text(caption).font(FoodiaryTypography.pulseCaption).foregroundColor(FoodiaryDesign.pulseMuted)
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
            Circle().fill(color).frame(width: 9, height: 9)
            Text(label).font(FoodiaryTypography.pulseCaption).foregroundColor(FoodiaryDesign.pulseMuted)
            Text(value).font(.system(size: 12, weight: .bold, design: .default)).foregroundColor(FoodiaryDesign.pulseInk)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
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
            Text(emoji).font(.system(size: 26))
                .frame(width: 50, height: 50)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(FoodiaryDesign.pulseMealTint(for: mealType)))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(FoodiaryDesign.pulseMealAccent(for: mealType).opacity(0.24), lineWidth: 1))
            if showsLabel {
                Text(mealType.displayName).font(FoodiaryTypography.pulseLabel).foregroundColor(FoodiaryDesign.pulseMuted).lineLimit(1)
            }
        }
    }
}
