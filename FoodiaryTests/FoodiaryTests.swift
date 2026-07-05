import Testing
import SwiftData
@testable import Foodiary

/// A lightweight in-memory PersistenceService for unit tests.
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

    func delete<T: PersistentModel>(_ model: T) {
        let key = String(describing: T.self)
        models[key]?.removeAll { _ in true } // simplified
    }

    func save() throws {}
}

struct FoodiaryTests {
    @Test func appStateInitialization() async throws {
        let persistence = MockPersistence()
        let state = AppState(persistence: persistence)
        #expect(state.selectedLanguage == "id")
        #expect(state.profile == nil)
    }
}
