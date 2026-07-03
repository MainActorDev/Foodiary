import SwiftUI

// MARK: - Manual Food Form

struct ManualFoodFormView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    @Binding var name: String
    @Binding var caloriesText: String
    @Binding var proteinText: String
    @Binding var carbsText: String
    @Binding var fatText: String
    @Binding var note: String
    @Binding var nameError: Bool
    @Binding var caloriesError: Bool
    var onSave: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.food_name"]).pulseSectionLabel()
                    TextField(L10n["add_food.name_placeholder"], text: $name)
                        .ringField().font(FoodiaryTypography.body)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(nameError ? Color.red : FoodiaryDesign.border, lineWidth: 1.5))
                    if nameError {
                        Text(L10n["add_food.name_error"]).font(.system(size: 12)).foregroundColor(.red)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.calories"]).pulseSectionLabel()
                    TextField("0", text: $caloriesText)
                        .keyboardType(.numberPad).ringField().font(FoodiaryTypography.body)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(caloriesError ? Color.red : FoodiaryDesign.border, lineWidth: 1.5))
                    Text(L10n["add_food.calories_hint"]).font(.system(size: 12)).foregroundColor(FoodiaryDesign.mutedFg)
                    if caloriesError {
                        Text(L10n["add_food.calories_error"]).font(.system(size: 12)).foregroundColor(.red)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.macronutrients"]).pulseSectionLabel()
                    HStack(spacing: 8) {
                        macroField(label: "Protein", unit: "g", text: $proteinText)
                        macroField(label: "Carbs", unit: "g", text: $carbsText)
                        macroField(label: "Fat", unit: "g", text: $fatText)
                    }
                    Text("Optional — enter grams for each macronutrient.").font(.system(size: 12)).foregroundColor(FoodiaryDesign.mutedFg)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.note_optional"]).pulseSectionLabel()
                    TextField(L10n["add_food.note_placeholder"], text: $note)
                        .ringField().font(FoodiaryTypography.body)
                }

                Spacer(minLength: 12)

                Button(action: onSave) { Text(L10n["action.save_food_item"]) }
                    .buttonStyle(PulsePrimaryButtonStyle())
            }
        }
        .padding(20)
    }

    private func macroField(label: String, unit: String, text: Binding<String>) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.system(size: 11, weight: .bold)).foregroundColor(FoodiaryDesign.mutedFg)
            TextField("0", text: text)
                .keyboardType(.numberPad).multilineTextAlignment(.center)
                .ringField().font(.system(size: 14, weight: .semibold))
        }
    }
}
