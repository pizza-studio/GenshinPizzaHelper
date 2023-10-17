import Foundation
@testable import HoYoKit
import XCTest

// MARK: - HBMihoyoAPITests

final class HBMihoyoAPITests: XCTestCase {
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

    func testDailyNoteAPIChina() async throws {
        do {
            _ = try await MiHoYoAPI.dailyNote(
                server: TestData.China.server,
                uid: TestData.China.uid,
                cookie: TestData.China.testCookie,
                deviceFingerPrint: nil
            )
        } catch MiHoYoAPIError.verificationNeeded {
            print("China API need verification")
        } catch {
            throw error
        }
    }

    func testDailyNoteAPIGlobal() async throws {
        _ = try await MiHoYoAPI.dailyNote(server: TestData.Global.server, uid: TestData.Global.uid, cookie: TestData.Global.testCookie, deviceFingerPrint: nil)
    }

    func testWidgetDailyNoteAPIChina() async throws {
        _ = try await MiHoYoAPI.widgetDailyNote(cookie: TestData.China.testCookie, deviceFingerPrint: nil)
    }

    func testGetSTokenV2API() async throws {
        _ = try await MiHoYoAPI.sTokenV2(cookie: TestData.China.testCookie)
    }
}

enum TestData {
    enum China {
        static let uid = "114514001"

        static let server: Server = .china

        static let testCookie = """
        stuid=114514004; stoken=SANITIZED ltuid=114514004; ltoken=SANITIZED
        """
    }

    enum Global {
        static let uid = "114514006"

        static let server: Server = .asia

        static let testCookie = """
        G_ENABLED_IDPS=google; _MHYUUID=2b816df6-9164-437a-8bcb-6ae7f29a0878; DEVICEFP=38d7eaa5fef19; mi18nLang=en-us; _ga=GA1.2.2114925491.1663166136; _gid=GA1.2.1006187314.1663166136; DEVICEFP_SEED_ID=130a980a314cfc57; DEVICEFP_SEED_TIME=1663166136479; ltoken=SANITIZED ltuid=208504340; cookie_token=SANITIZED account_id=208504340; 
        """
    }
}


