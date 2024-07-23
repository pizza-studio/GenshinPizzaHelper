@testable import GIPizzaKit
import XCTest

final class GMDBSputnikTests: XCTestCase {
    func testFetchingPreCompiledData() async throws {
        let data = try await GachaMetaDBExposed.Sputnik.fetchPreCompiledData()
        XCTAssertTrue(!data.isEmpty)
    }
}
