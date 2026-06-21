import SwiftUI
import SwiftData
import CoreText

@main
struct FoodiaryApp: App {
    let container: ModelContainer
    
    init() {
        // Bootstrap localization before any view renders
        LocaleManager.bootstrap()
        
        do {
            container = try ModelContainer(for:
                UserProfile.self, CalorieTarget.self,
                MealPlan.self, Meal.self, FoodItem.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        
        // One-time migration from JSON
        MigrationService.migrateFromJSONIfNeeded(container: container)
        
        // Global nav bar styling
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(FoodiaryDesign.background)
        appearance.shadowColor = .clear
        
        let titleFont: UIFont = {
            let ctFont = CTFontCreateWithName("Space Grotesk" as CFString, 18, nil)
            if let boldCT = CTFontCreateCopyWithSymbolicTraits(ctFont, 0, nil, .boldTrait, .boldTrait) {
                return boldCT as UIFont
            }
            return UIFont.systemFont(ofSize: 18, weight: .bold)
        }()
        let largeTitleFont: UIFont = {
            let ctFont = CTFontCreateWithName("Space Grotesk" as CFString, 28, nil)
            if let boldCT = CTFontCreateCopyWithSymbolicTraits(ctFont, 0, nil, .boldTrait, .boldTrait) {
                return boldCT as UIFont
            }
            return UIFont.systemFont(ofSize: 28, weight: .bold)
        }()
        
        appearance.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: UIColor(FoodiaryDesign.black)
        ]
        appearance.largeTitleTextAttributes = [
            .font: largeTitleFont,
            .foregroundColor: UIColor(FoodiaryDesign.black)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(FoodiaryDesign.black)
        
        // Tab bar styling
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(FoodiaryDesign.white)
        tabAppearance.shadowColor = UIColor(FoodiaryDesign.black)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentRootView()
                .modelContainer(container)
        }
    }
}
