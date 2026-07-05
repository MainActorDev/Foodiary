import Testing
@testable import Foodiary

struct FoodiaryTests {
    @Test func appStateInitialization() async throws {
        // Verify AppState initializes without crashing
        let state = await AppState()
        #expect(state.selectedLanguage == "id")
        #expect(state.profile == nil)
    }
}
