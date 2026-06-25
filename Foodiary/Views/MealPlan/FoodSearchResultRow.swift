import SwiftUI

// MARK: - Food Search Result Row

struct FoodSearchResultRow: View {
    let result: FoodSearchResult

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(result.name)
                    .font(FoodiaryTypography.bodyBold)
                    .foregroundColor(FoodiaryDesign.black)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if let brand = result.brand, !brand.isEmpty {
                        Text(brand).font(.system(size: 12)).foregroundColor(FoodiaryDesign.mutedFg).lineLimit(1)
                    }
                    if let serving = result.servingDescription, !serving.isEmpty {
                        Text("·").foregroundColor(FoodiaryDesign.mutedFg)
                        Text(serving).font(.system(size: 12)).foregroundColor(FoodiaryDesign.mutedFg).lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(result.calories) kcal")
                    .font(FoodiaryTypography.bodyBold)
                    .foregroundColor(FoodiaryDesign.pulsePrimary)

                Text(result.sourceDisplayName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: 4).fill(sourceBadgeColor))
            }
        }
        .padding(.vertical, 12).padding(.horizontal, 14)
        .contentShape(Rectangle())
    }

    private var sourceBadgeColor: Color {
        switch result.source {
        case .fatsecret: return Color(hex: "059669")
        case .custom: return FoodiaryDesign.accent
        case .usda: return Color(hex: "D97706")
        case .openFoodFacts: return Color(hex: "7C3AED")
        }
    }
}
