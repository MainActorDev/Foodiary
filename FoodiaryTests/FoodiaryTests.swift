import Testing
import SwiftData
@testable import Foodiary

@MainActor
final class MockPersistence: PersistenceService {
    var models: [String: [Any]] = [:]

    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        let key = String(describing: T.self)
        return (models[key] as? [T]) ?? []
    }

    func insert<T: PersistentModel>(_ model: T) {
        let key = String(describing: T.self)
        models[key, default: []].append(model)
    }

    func delete<T: PersistentModel>(_ model: T) {}

    func save() throws {}
}

@MainActor
struct FoodiaryTests {
    @Test func initialState() async throws {
        let persistence = MockPersistence()
        let state = AppState(persistence: persistence)
        #expect(state.isOnboarded == false)
        #expect(state.userProfile == nil)
        #expect(state.targetCalories == 2000)
    }
}
