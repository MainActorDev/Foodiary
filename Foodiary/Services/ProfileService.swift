import Foundation
import SwiftData

/// Manages profile and calorie target persistence.
///
/// Extracted from `AppState` to enforce single responsibility.
/// Depends on `PersistenceService` rather than concrete `ModelContext`.
@MainActor
final class ProfileService {
    private let persistence: any PersistenceService

    init(persistence: any PersistenceService) {
        self.persistence = persistence
    }

    // MARK: - Profile

    /// Fetch the current user profile (single-row table).
    func fetchProfile() -> UserProfile? {
        var fetch = FetchDescriptor<UserProfile>()
        fetch.fetchLimit = 1
        return try? persistence.fetch(fetch).first
    }

    /// Save or overwrite the user profile.
    func saveProfile(_ profile: UserProfile) {
        if let existing = fetchProfile() {
            persistence.delete(existing)
        }
        let p = profile
        p.updatedAt = Date()
        persistence.insert(p)
        do {
            try persistence.save()
        } catch {
            print("[ProfileService] Failed to save profile: \(error)")
        }
    }

    // MARK: - Calorie Target

    /// Calculate and persist a calorie target for the given profile.
    func calculateAndSaveTarget(for profile: UserProfile) {
        let target = CalorieCalculator.calculate(for: profile)
        target.profile = profile
        profile.calorieTarget = target
        persistence.insert(target)
        do {
            try persistence.save()
        } catch {
            print("[ProfileService] Failed to save calorie target: \(error)")
        }
    }

    // MARK: - Reset

    /// Delete all user data (profile, targets, meal plans, food items).
    func deleteAllData() {
        if let profiles = try? persistence.fetch(FetchDescriptor<UserProfile>()) {
            for profile in profiles { persistence.delete(profile) }
        }
        do {
            try persistence.save()
        } catch {
            print("[ProfileService] Failed to reset all data: \(error)")
        }
    }
}
