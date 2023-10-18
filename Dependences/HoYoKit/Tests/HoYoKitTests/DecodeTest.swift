import Foundation
@testable import HoYoKit
import XCTest

// MARK: - HBMihoyoAPITests

final class DecodeTests: XCTestCase {
    func testDailyNoteDecode() throws {
        let exampleURL = Bundle.module.url(forResource: "daily_note_example", withExtension: "json")!
        let exampleData = try Data(contentsOf: exampleURL)
        _ = try DailyNote.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }

    func testWidgetDailyNoteDecode() throws {
        let exampleURL = Bundle.module.url(forResource: "widget_daily_note_example", withExtension: "json")!
        let exampleData = try Data(contentsOf: exampleURL)
        _ = try WidgetDailyNote.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }

    func testLedgerDataChinaDecode() throws {
        let exampleURL = Bundle.module.url(forResource: "ledger_data_china", withExtension: "json")!
        let exampleData = try Data(contentsOf: exampleURL)
        _ = try LedgerData.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }

    func testLedgerDataGlobalDecode() throws {
        let exampleURL = Bundle.module.url(forResource: "ledger_data_global", withExtension: "json")!
        let exampleData = try Data(contentsOf: exampleURL)
        _ = try LedgerData.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }

    func testBasicInfoDecode() throws {
        let exampleURL = Bundle.module.url(forResource: "basic_info_data", withExtension: "json")!
        let exampleData = try Data(contentsOf: exampleURL)
        _ = try BasicInfos.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }

    func testAbyssDecode() throws {
        let exampleURL = Bundle.module.url(forResource: "abyss_data", withExtension: "json")!
        let exampleData = try Data(contentsOf: exampleURL)
        _ = try SpiralAbyssDetail.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }

    func testAllAvatarDecode() throws {
        let exampleURL = Bundle.module.url(forResource: "all_avatar_data", withExtension: "json")!
        let exampleData = try Data(contentsOf: exampleURL)
        _ = try AllAvatarDetailModel.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }
}
