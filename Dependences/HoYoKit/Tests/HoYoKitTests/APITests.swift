import Foundation
@testable import HoYoKit
import XCTest

// MARK: - APITests

final class APITests: XCTestCase {
    func testGetFingerPrint() async throws {
        _ = try await MiHoYoAPI.getDeviceFingerPrint(deviceId: UUID())
    }

    func testGeneralDailyNoteAPIChina() async throws {
        do {
            _ = try await MiHoYoAPI.generalDailyNote(
                server: TestData.China.server,
                uid: TestData.China.uid,
                cookie: TestData.China.testCookie,
                deviceFingerPrint: TestData.China.deviceFingerPrint,
                deviceId: TestData.China.deviceId
            )
        } catch MiHoYoAPIError.verificationNeeded {
            print("China API need verification")
        } catch {
            throw error
        }
    }

    func testGeneralDailyNoteAPIGlobal() async throws {
        _ = try await MiHoYoAPI.generalDailyNote(
            server: TestData.Global.server,
            uid: TestData.Global.uid,
            cookie: TestData.Global.testCookie,
            deviceFingerPrint: nil,
            deviceId: nil
        )
    }

    func testDailyNoteAPIChina() async throws {
        do {
            _ = try await MiHoYoAPI.dailyNote(
                server: TestData.China.server,
                uid: TestData.China.uid,
                cookie: TestData.China.testCookie,
                deviceFingerPrint: TestData.China.deviceFingerPrint,
                deviceId: TestData.China.deviceId
            )
        } catch MiHoYoAPIError.verificationNeeded {
            print("China API need verification")
        } catch {
            throw error
        }
    }

    func testDailyNoteAPIGlobal() async throws {
        _ = try await MiHoYoAPI.dailyNote(
            server: TestData.Global.server,
            uid: TestData.Global.uid,
            cookie: TestData.Global.testCookie,
            deviceFingerPrint: nil,
            deviceId: nil
        )
    }

    func testWidgetDailyNoteAPIChina() async throws {
        _ = try await MiHoYoAPI.widgetDailyNote(
            cookie: TestData.China.testCookie,
            deviceFingerPrint: nil,
            deviceId: nil
        )
    }

    func testGetSTokenV2API() async throws {
        _ = try await MiHoYoAPI.sTokenV2(cookie: TestData.China.testCookie)
    }

    func testGetCookieTokenAPI() async throws {
        _ = try await MiHoYoAPI.cookieToken(cookie: TestData.China.testCookie)
    }

    func testLedgerDataAPIChina() async throws {
        _ = try await MiHoYoAPI.ledgerData(
            month: 0,
            uid: TestData.China.uid,
            server: TestData.China.server,
            cookie: TestData.China.testCookie
        )
    }

    func testLedgerDataAPIGlobal() async throws {
        _ = try await MiHoYoAPI.ledgerData(
            month: 0,
            uid: TestData.Global.uid,
            server: TestData.Global.server,
            cookie: TestData.Global.testCookie
        )
    }

    func testBasicInfoAPIChina() async throws {
        do {
            _ = try await MiHoYoAPI.basicInfo(
                server: TestData.China.server,
                uid: TestData.China.uid,
                cookie: TestData.China.testCookie,
                deviceFingerPrint: TestData.China.deviceFingerPrint,
                deviceId: TestData.China.deviceId
            )
        } catch MiHoYoAPIError.verificationNeeded {
            print("China API need verification")
        } catch {
            throw error
        }
    }

    func testBasicInfoAPIGlobal() async throws {
        _ = try await MiHoYoAPI.basicInfo(
            server: TestData.Global.server,
            uid: TestData.Global.uid,
            cookie: TestData.Global.testCookie,
            deviceFingerPrint: nil, deviceId: nil
        )
    }

    func testAbyssAPIChina() async throws {
        do {
            _ = try await MiHoYoAPI.abyssData(
                round: .this,
                server: TestData.China.server,
                uid: TestData.China.uid,
                cookie: TestData.China.testCookie,
                deviceFingerPrint: TestData.China.deviceFingerPrint,
                deviceId: TestData.China.deviceId
            )
        } catch MiHoYoAPIError.verificationNeeded {
            print("China API need verification")
        } catch {
            throw error
        }
    }

    func testAbyssAPIGlobal() async throws {
        _ = try await MiHoYoAPI.abyssData(
            round: .this,
            server: TestData.Global.server,
            uid: TestData.Global.uid,
            cookie: TestData.Global.testCookie,
            deviceFingerPrint: nil, deviceId: nil
        )
    }

    func testAllAvatarAPIChina() async throws {
        do {
            _ = try await MiHoYoAPI.allAvatarDetail(
                server: TestData.China.server,
                uid: TestData.China.uid,
                cookie: TestData.China.testCookie,
                deviceFingerPrint: TestData.China.deviceFingerPrint, deviceId: TestData.China.deviceId
            )
        } catch MiHoYoAPIError.verificationNeeded {
            print("China API need verification")
        } catch {
            throw error
        }
    }

    func testAllAvatarAPIGlobal() async throws {
        _ = try await MiHoYoAPI.allAvatarDetail(
            server: TestData.Global.server,
            uid: TestData.Global.uid,
            cookie: TestData.Global.testCookie,
            deviceFingerPrint: nil, deviceId: nil
        )
    }
}

// MARK: - TestData

enum TestData {
    enum China {
        static let uid = "114514001"

        static let server: Server = .china

        static let testCookie = """
        stuid=114514004; stoken=SANITIZED ltuid=114514004; ltoken=SANITIZED
        """

        static let deviceFingerPrint = "1145141919810"
        static let deviceId = UUID()
    }

    enum Global {
        static let uid = "114514006"

        static let server: Server = .asia

        static let testCookie = """
        G_ENABLED_IDPS=google; _MHYUUID=2b816df6-9164-437a-8bcb-6ae7f29a0878; DEVICEFP=38d7eaa5fef19; mi18nLang=en-us; _ga=GA1.2.2114925491.1663166136; _gid=GA1.2.1006187314.1663166136; DEVICEFP_SEED_ID=130a980a314cfc57; DEVICEFP_SEED_TIME=1663166136479; ltoken=SANITIZED ltuid=208504340; cookie_token=SANITIZED account_id=208504340; 
        """
    }
}
