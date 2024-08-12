@testable import GIPizzaKit
import XCTest

final class GMDBSputnikTests: XCTestCase {
    func testFetchingPreCompiledData() async throws {
        let data = try await GachaMetaDBExposed.Sputnik.fetchPreCompiledData()
        XCTAssertTrue(!data.isEmpty)
    }

    func testDumpData() async throws {
        #if DEBUG
        let data = DataDumper.dumpArtifactModelDataNeo()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
        let newStr = String(data: try encoder.encode(data), encoding: .utf8)
        print(newStr ?? "")
        #endif
    }
}
