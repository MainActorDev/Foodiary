import SwiftUI

/// Rich card showing a food search result with full macro breakdown.
/// Tapping Add calls `onAdd` immediately — no detail screen navigation.
struct FoodResultCard: View {
    let result: FoodSearchResult
    var onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: source badge + name + serving
            VStack(alignment: .leading, spacing: 4) {
                SourceBadge(source: result.source)
                Text(result.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(FoodiaryDesign.pulseInk)
                    .lineLimit(2)
                if let serving = result.servingDescription, !serving.isEmpty {
                    Text(serving)
                        .font(.system(size: 12))
                        .foregroundColor(FoodiaryDesign.pulseMuted)
                }
            }

            // Macro grid: 4 columns
            HStack(spacing: 6) {
                MacroTile(value: "\(result.calories)", label: "kcal")
                MacroTile(value: "\(result.protein)g", label: "Protein")
                MacroTile(value: "\(result.carbs)g", label: "Carbs")
                MacroTile(value: "\(result.fat)g", label: "Fat")
            }

            // Add button — full width
            Button(action: onAdd) {
                Text(L10n["add_food.add_button"])
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(FoodiaryDesign.pulsePrimary))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(FoodiaryDesign.pulseSurface))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1))
    }
}

// MARK: - Skeleton Card

/// Shimmer placeholder card shown during search loading.
struct FoodResultCardSkeleton: View {
    @State private var animateShimmer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                skeletonBlock(width: 60, height: 14)
                skeletonBlock(width: 200, height: 18)
                skeletonBlock(width: 100, height: 12)
            }

            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(FoodiaryDesign.pulseSurfaceSoft)
                        .frame(height: 44)
                        .overlay(shimmerOverlay)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            RoundedRectangle(cornerRadius: 14)
                .fill(FoodiaryDesign.pulseSurfaceSoft)
                .frame(height: 44)
                .overlay(shimmerOverlay)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(FoodiaryDesign.pulseSurface))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(FoodiaryDesign.pulseBorder, lineWidth: 1))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                animateShimmer = true
            }
        }
    }

    private var shimmerOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        FoodiaryDesign.pulseInk.opacity(animateShimmer ? 0.06 : 0.02),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }

    private func skeletonBlock(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(FoodiaryDesign.pulseSurfaceSoft)
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                FoodiaryDesign.pulseInk.opacity(animateShimmer ? 0.06 : 0.02),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
    }
}

// MARK: - Macro Tile

private struct MacroTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(FoodiaryDesign.pulseInk)
            Text(label)
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(FoodiaryDesign.pulseMuted)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(FoodiaryDesign.pulseSurfaceSoft))
    }
}

// MARK: - Source Badge

private struct SourceBadge: View {
    let source: FoodDatabaseSource

    private var color: Color {
        switch source {
        case .fatsecret: return FoodiaryDesign.pulseMint
        case .custom: return FoodiaryDesign.pulsePrimary
        case .usda: return FoodiaryDesign.pulseAmber
        case .openFoodFacts: return Color(hex: "7C3AED")
        }
    }

    var body: some View {
        Text(source.sourceDisplayName)
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(RoundedRectangle(cornerRadius: 6).fill(color.opacity(0.12)))
    }
}
