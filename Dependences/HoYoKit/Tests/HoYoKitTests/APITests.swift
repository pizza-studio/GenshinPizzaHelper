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

//    func testDailyNoteAPIChina() async throws {
//        do {
//            _ = try await MiHoYoAPI.dailyNote(
//                server: TestData.China.server,
//                uid: TestData.China.uid,
//                cookie: TestData.China.testCookie,
//                deviceFingerPrint: TestData.China.deviceFingerPrint,
//                deviceId: TestData.China.deviceId
//            )
//        } catch MiHoYoAPIError.verificationNeeded {
//            print("China API need verification")
//        } catch {
//            throw error
//        }
//    }
//
//    func testDailyNoteAPIGlobal() async throws {
//        _ = try await MiHoYoAPI.dailyNote(
//            server: TestData.Global.server,
//            uid: TestData.Global.uid,
//            cookie: TestData.Global.testCookie,
//            deviceFingerPrint: nil,
//            deviceId: nil
//        )
//    }
//
//    func testWidgetDailyNoteAPIChina() async throws {
//        _ = try await MiHoYoAPI.widgetDailyNote(
//            cookie: TestData.China.testCookie,
//            deviceFingerPrint: nil,
//            deviceId: nil
//        )
//    }

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

    func testGenerateQRCodeURL() async throws {
        let uuid = UUID()
        let result = try await MiHoYoAPI.generateQRCodeURL(deviceId: uuid)
        print(result)
        print("UUID: \(uuid.uuidString)")

        let ticket = result.ticket
        let deviceId = uuid
        while true {
            let result = try await MiHoYoAPI.queryQRCodeStatus(deviceId: deviceId, ticket: ticket)
            print(result)

            if case .confirmed = result { break }

            try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
        }
    }

    func testQueryQRCodeStatus() async throws {
        let ticket = ""
        let deviceId = UUID(uuidString: "8FE68837-9A62-4426-9345-5792E497E591")!
        let result = try await MiHoYoAPI.queryQRCodeStatus(deviceId: deviceId, ticket: ticket)
        print(result)
    }

    func testGameToken2StokenV2() async throws {
        let gameToken = ""
        let accountId = ""
        let result = try await MiHoYoAPI.gameToken2StokenV2(accountId: accountId, gameToken: gameToken)
        print(result)
    }

    func testStoken2LTokenV1() async throws {
        let stoken =
            ""
        let mid = ""
        let result = try await MiHoYoAPI.stoken2LTokenV1(mid: mid, stoken: stoken)
        print(result)
    }
}

// MARK: - TestData

enum TestData {
    enum China {
        static let uid = ""

        static let server: Server = .china

        static let testCookie = ""

        static let deviceFingerPrint = ""
        static let deviceId = UUID()
    }

    enum Global {
        static let uid = ""

        static let server: Server = .asia

        static let testCookie = ""
    }
}
