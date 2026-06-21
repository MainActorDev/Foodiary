import SwiftUI

struct AddFoodItemView: View {
    var onSave: (FoodItem) -> Void
    var onCancel: () -> Void
    
    @State private var name = ""
    @State private var caloriesText = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatText = ""
    @State private var note = ""
    @State private var nameError = false
    @State private var caloriesError = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.food_name"]).sectionLabel()
                    TextField(L10n["add_food.name_placeholder"], text: $name)
                        .ringField()
                        .font(FoodiaryTypography.body)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(nameError ? Color.red : FoodiaryDesign.border, lineWidth: 1.5)
                        )
                    if nameError {
                        Text(L10n["add_food.name_error"])
                            .font(.system(size: 12)).foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.calories"]).sectionLabel()
                    TextField("0", text: $caloriesText)
                        .keyboardType(.numberPad)
                        .ringField()
                        .font(FoodiaryTypography.body)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(caloriesError ? Color.red : FoodiaryDesign.border, lineWidth: 1.5)
                        )
                    Text(L10n["add_food.calories_hint"])
                        .font(.system(size: 12))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                    if caloriesError {
                        Text(L10n["add_food.calories_error"])
                            .font(.system(size: 12)).foregroundColor(.red)
                    }
                }
                
                // Macro fields
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.macronutrients"]).sectionLabel()
                    HStack(spacing: 8) {
                        macroField(label: "Protein", unit: "g", text: $proteinText)
                        macroField(label: "Carbs", unit: "g", text: $carbsText)
                        macroField(label: "Fat", unit: "g", text: $fatText)
                    }
                    Text("Optional — enter grams for each macronutrient.")
                        .font(.system(size: 12))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n["label.note_optional"]).sectionLabel()
                    TextField(L10n["add_food.note_placeholder"], text: $note)
                        .ringField()
                        .font(FoodiaryTypography.body)
                }
                
                Spacer(minLength: 12)
                
                Button(action: saveItem) {
                    Text(L10n["action.save_food_item"])
                }
                .buttonStyle(RingButtonStyle())
                
                Button(action: onCancel) {
                    Text(L10n["action.cancel"])
                }
                .buttonStyle(RingSecondaryButtonStyle())
            }
            .padding(20)
        }
        .background(FoodiaryDesign.background)
        .navigationTitle(L10n["nav.add_food"])
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(RingStepperButtonStyle())
            }
        }
    }
    
    func macroField(label: String, unit: String, text: Binding<String>) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(FoodiaryDesign.mutedFg)
            TextField("0", text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .ringField()
                .font(.system(size: 14, weight: .semibold))
        }
    }
    
    private func saveItem() {
        nameError = name.trimmingCharacters(in: .whitespaces).isEmpty
        caloriesError = false
        
        guard !nameError else { return }
        
        guard let calories = Int(caloriesText.trimmingCharacters(in: .whitespaces)), calories >= 0 else {
            caloriesError = true
            return
        }
        
        let protein = Int(proteinText.trimmingCharacters(in: .whitespaces)) ?? 0
        let carbs = Int(carbsText.trimmingCharacters(in: .whitespaces)) ?? 0
        let fat = Int(fatText.trimmingCharacters(in: .whitespaces)) ?? 0
        
        let item = FoodItem(
            name: name.trimmingCharacters(in: .whitespaces),
            calories: calories,
            protein: max(0, protein),
            carbs: max(0, carbs),
            fat: max(0, fat),
            note: note.trimmingCharacters(in: .whitespaces)
        )
        onSave(item)
    }
}
