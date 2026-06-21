import Foundation
import SwiftData

enum MigrationService {
    private static let didMigrateKey = "didMigrateToSwiftData"
    
    @MainActor
    static func migrateFromJSONIfNeeded(container: ModelContainer) {
        guard !UserDefaults.standard.bool(forKey: didMigrateKey) else { return }
        
        let context = container.mainContext
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // 1. Migrate profile → UserProfile
        let profileURL = documentsURL.appendingPathComponent("profile.json")
        if let data = try? Data(contentsOf: profileURL),
           let oldProfile = try? JSONDecoder().decode(OldUserProfile.self, from: data) {
            let profile = UserProfile(
                age: oldProfile.age,
                sex: UserProfile.Sex(rawValue: oldProfile.sex) ?? .female,
                heightCm: oldProfile.heightCm,
                weightKg: oldProfile.weightKg,
                activityLevel: UserProfile.ActivityLevel(rawValue: oldProfile.activityLevel) ?? .sedentary,
                goal: UserProfile.Goal(rawValue: oldProfile.goal) ?? .maintain
            )
            context.insert(profile)
            
            // 2. Migrate target → CalorieTarget
            let targetURL = documentsURL.appendingPathComponent("target.json")
            if let tData = try? Data(contentsOf: targetURL),
               let oldTarget = try? JSONDecoder().decode(OldCalorieTarget.self, from: tData) {
                let target = CalorieTarget(
                    bmr: oldTarget.bmr,
                    maintenanceCalories: oldTarget.maintenanceCalories,
                    targetCalories: oldTarget.targetCalories
                )
                target.profile = profile
                profile.calorieTarget = target
                context.insert(target)
            }
        }
        
        // 3. Migrate meal plans
        let fm = FileManager.default
        if let files = try? fm.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil) {
            for file in files where file.lastPathComponent.hasPrefix("mealplan_") {
                guard let data = try? Data(contentsOf: file),
                      let oldPlan = try? JSONDecoder().decode(OldMealPlan.self, from: data) else { continue }
                let plan = MealPlan(date: oldPlan.date, targetCalories: oldPlan.targetCalories)
                for oldMeal in oldPlan.meals {
                    let meal = Meal(type: Meal.MealType(rawValue: oldMeal.type) ?? .breakfast)
                    for oldItem in oldMeal.items {
                        let item = FoodItem(
                            name: oldItem.name,
                            calories: oldItem.calories,
                            protein: oldItem.protein,
                            carbs: oldItem.carbs,
                            fat: oldItem.fat,
                            note: oldItem.note
                        )
                        item.meal = meal
                        meal.items.append(item)
                    }
                    meal.mealPlan = plan
                    plan.meals.append(meal)
                }
                context.insert(plan)
            }
        }
        
        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: didMigrateKey)
        } catch {
            print("[MigrationService] Migration failed: \(error) — will retry on next launch")
        }
    }
}

// MARK: - Old Codable models (for migration decoding only)

private struct OldUserProfile: Codable {
    var age: Int
    var sex: String
    var heightCm: Double
    var weightKg: Double
    var activityLevel: String
    var goal: String
}

private struct OldCalorieTarget: Codable {
    var bmr: Int
    var maintenanceCalories: Int
    var targetCalories: Int
}

private struct OldMealPlan: Codable {
    var date: Date
    var targetCalories: Int
    var meals: [OldMeal]
}

private struct OldMeal: Codable {
    var type: String
    var items: [OldFoodItem]
}

private struct OldFoodItem: Codable {
    var name: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    var note: String
}
