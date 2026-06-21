import SwiftUI

struct MealDetailView: View {
    @ObservedObject var state: AppState
    let mealIndex: Int
    var date: Date = Date()  // Default to today for backward compat
    @Binding var isPresented: Bool
    @State private var showAddFood = false
    
    var mealPlan: MealPlan? {
        if Calendar.current.isDateInToday(date) {
            return state.todayMealPlan
        }
        return state.planDateMealPlan
    }
    
    var meal: Meal? {
        guard let plan = mealPlan, mealIndex < plan.meals.count else { return nil }
        return plan.meals[mealIndex]
    }
    
    /// Whether this is a past day (view-only)
    var isReadOnly: Bool {
        date < Calendar.current.startOfDay(for: Date())
    }
    
    var body: some View {
        Group {
            if let meal = meal {
                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Text(L10n["label.food_items"])
                                .sectionLabel()
                            Spacer()
                            Text("\(meal.totalCalories) \(L10n["unit.kcal"])")
                                .font(FoodiaryTypography.bodySm)
                                .foregroundColor(FoodiaryDesign.mutedFg)
                        }
                        
                        VStack(spacing: 0) {
                            if meal.items.isEmpty {
                                VStack(spacing: 8) {
                                    Text(L10n["meal_detail.empty.title"])
                                        .font(FoodiaryTypography.bodySm)
                                        .foregroundColor(FoodiaryDesign.mutedFg)
                                    Text(L10n["meal_detail.empty.subtitle"])
                                        .font(FoodiaryTypography.bodySm)
                                        .foregroundColor(FoodiaryDesign.mutedFg)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(24)
                            } else {
                                ForEach(Array(meal.items.enumerated()), id: \.element.id) { itemIndex, item in
                                    FoodItemRowView(
                                        item: item,
                                        isReadOnly: isReadOnly,
                                        onDelete: {
                                            if Calendar.current.isDateInToday(date) {
                                                state.deleteFoodItem(mealIndex: mealIndex, itemIndex: itemIndex)
                                            } else {
                                                state.deleteFoodItem(mealIndex: mealIndex, itemIndex: itemIndex, for: date)
                                            }
                                        }
                                    )
                                    
                                    if itemIndex < meal.items.count - 1 {
                                        Divider()
                                            .overlay(FoodiaryDesign.muted)
                                    }
                                }
                            }
                        }
                        .nbCard()
                        
                        if !isReadOnly {
                            Button(action: { showAddFood = true }) {
                                Text(L10n["action.add_food"])
                            }
                            .buttonStyle(NBButtonStyle())
                        }
                    }
                    .padding(20)
                }
                .background(FoodiaryDesign.background)
                .navigationTitle(meal.type.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(NBStepperButtonStyle())
                    }
                    if !isReadOnly {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { showAddFood = true }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .buttonStyle(NBStepperButtonStyle())
                        }
                    }
                }
                .sheet(isPresented: $showAddFood) {
                    NavigationStack {
                        AddFoodItemView(
                            onSave: { item in
                                if Calendar.current.isDateInToday(date) {
                                    state.addFoodItem(item, toMealAt: mealIndex)
                                } else {
                                    state.addFoodItem(item, toMealAt: mealIndex, for: date)
                                }
                                showAddFood = false
                            },
                            onCancel: { showAddFood = false }
                        )
                    }
                }
            }
        }
    }
}

struct FoodItemRowView: View {
    let item: FoodItem
    var isReadOnly: Bool = false
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(FoodiaryTypography.bodyBold)
                    .foregroundColor(FoodiaryDesign.black)
                if !item.note.isEmpty {
                    Text(item.note)
                        .font(.system(size: 12))
                        .foregroundColor(FoodiaryDesign.mutedFg)
                }
            }
            
            Spacer()
            
            Text("\(item.calories) \(L10n["unit.kcal"])")
                .font(FoodiaryTypography.bodyBold)
                .foregroundColor(FoodiaryDesign.black)
            
            if !isReadOnly {
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                }
                .buttonStyle(NBIconButtonStyle(isDanger: true))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}
