import SwiftUI

struct AddFoodItemView: View {
    var onSave: (FoodItem) -> Void
    var onCancel: () -> Void
    
    @State private var name = ""
    @State private var caloriesText = ""
    @State private var note = ""
    @State private var nameError = false
    @State private var caloriesError = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("FOOD NAME")
                        .sectionLabel()
                    TextField("e.g. Chicken breast", text: $name)
                        .nbField()
                        .font(FoodiaryTypography.body)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(nameError ? Color.red : FoodiaryDesign.black, lineWidth: 3)
                        )
                    if nameError {
                        Text("Please enter a food name.")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("CALORIES")
                        .sectionLabel()
                    TextField("0", text: $caloriesText)
                        .keyboardType(.numberPad)
                        .nbField()
                        .font(FoodiaryTypography.body)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(caloriesError ? Color.red : FoodiaryDesign.black, lineWidth: 3)
                        )
                    Text("Whole number, 0 or greater.")
                        .font(.system(size: 12))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                    if caloriesError {
                        Text("Please enter a valid calorie amount.")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("NOTE (OPTIONAL)")
                        .sectionLabel()
                    TextField("e.g. Grilled, no oil", text: $note)
                        .nbField()
                        .font(FoodiaryTypography.body)
                }
                
                Spacer(minLength: 16)
                
                Button(action: saveItem) {
                    Text("SAVE FOOD ITEM")
                }
                .buttonStyle(NBButtonStyle())
                
                Button(action: onCancel) {
                    Text("CANCEL")
                }
                .buttonStyle(NBSecondaryButtonStyle())
            }
            .padding(20)
        }
        .background(FoodiaryDesign.background)
        .navigationTitle("Add Food")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(NBStepperButtonStyle())
            }
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
        
        let item = FoodItem(
            name: name.trimmingCharacters(in: .whitespaces),
            calories: calories,
            note: note.trimmingCharacters(in: .whitespaces)
        )
        onSave(item)
    }
}
