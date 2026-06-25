import Foundation
import SwiftData

// MARK: - Protocol

/// Abstract persistence operations.
///
/// AppState and domain services depend on this protocol rather than
/// on `ModelContext` directly — enabling unit testing (with a mock),
/// future persistence swaps, and separation of concerns.
///
/// The production implementation is `SwiftDataPersistenceService`.
@MainActor
protocol PersistenceService: AnyObject {
    /// Fetch models matching a descriptor.
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T]

    /// Insert a new model into the store.
    func insert<T: PersistentModel>(_ model: T)

    /// Delete a model from the store.
    func delete<T: PersistentModel>(_ model: T)

    /// Persist all pending changes.
    func save() throws
}

// MARK: - Production Implementation

/// SwiftData-backed implementation of `PersistenceService`.
///
/// Wraps a `ModelContext` and delegates all operations to it.
/// Must be used on the main actor (SwiftData requirement).
@MainActor
final class SwiftDataPersistenceService: PersistenceService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        try context.fetch(descriptor)
    }

    func insert<T: PersistentModel>(_ model: T) {
        context.insert(model)
    }

    func delete<T: PersistentModel>(_ model: T) {
        context.delete(model)
    }

    func save() throws {
        try context.save()
    }
}
