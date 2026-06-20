import Foundation

/// JSON file-based persistence for local-first storage.
/// All data stored in the app's Documents directory.
enum StorageService {
    private static let documentsURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }()
    
    private static let profileURL = documentsURL.appendingPathComponent("profile.json")
    private static let targetURL = documentsURL.appendingPathComponent("target.json")
    
    private static func mealPlanURL(for date: Date) -> URL {
        documentsURL.appendingPathComponent("mealplan_\(MealPlan.dateKey(for: date)).json")
    }
    
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = .prettyPrinted
        return e
    }()
    
    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    // MARK: - Profile
    
    static func saveProfile(_ profile: UserProfile) throws {
        let data = try encoder.encode(profile)
        try data.write(to: profileURL, options: .atomic)
    }
    
    static func loadProfile() -> UserProfile? {
        guard let data = try? Data(contentsOf: profileURL) else { return nil }
        return try? decoder.decode(UserProfile.self, from: data)
    }
    
    // MARK: - Calorie Target
    
    static func saveTarget(_ target: CalorieTarget) throws {
        let data = try encoder.encode(target)
        try data.write(to: targetURL, options: .atomic)
    }
    
    static func loadTarget() -> CalorieTarget? {
        guard let data = try? Data(contentsOf: targetURL) else { return nil }
        return try? decoder.decode(CalorieTarget.self, from: data)
    }
    
    // MARK: - Meal Plan
    
    static func saveMealPlan(_ plan: MealPlan) throws {
        let url = mealPlanURL(for: plan.date)
        let data = try encoder.encode(plan)
        try data.write(to: url, options: .atomic)
    }
    
    static func loadMealPlan(for date: Date) -> MealPlan? {
        let url = mealPlanURL(for: date)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(MealPlan.self, from: data)
    }
    
    // MARK: - Reset
    
    static func resetAll() throws {
        let fm = FileManager.default
        let files = try fm.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        for file in files where file.pathExtension == "json" {
            try fm.removeItem(at: file)
        }
    }
    
    // MARK: - Calendar Helpers
    
    static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}
