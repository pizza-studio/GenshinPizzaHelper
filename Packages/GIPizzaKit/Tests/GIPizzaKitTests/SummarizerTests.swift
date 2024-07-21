@testable import GIPizzaKit
import XCTest

final class SummarizerTests: XCTestCase {
    /// 测试本地化
    func testAvatarInitiation() throws {
        let theAvatarRaw = try? JSONDecoder()
            .decode(
                EnkaGI.QueryRelated.ProfileRAW.AvatarInfoRAW.self,
                from: jsnYukuakiAvatar.data(using: .utf8) ?? .init([])
            )
        XCTAssertNotNil(theAvatarRaw)
        guard let theAvatarRaw = theAvatarRaw else { exit(1) }
        let enkaDB = EnkaGI.Sputnik.sharedDB
        let theAvatar = EnkaGI.QueryRelated.Avatar(
            avatarInfo: theAvatarRaw,
            localizedDictionary: enkaDB.locTable,
            characterDictionary: enkaDB.characters,
            uid: "1145141919810"
        )
        XCTAssertNotNil(theAvatar)
        guard let theAvatar = theAvatar else { exit(1) }
        print(theAvatar.summarize(locMap: enkaDB.locTable, useMarkDown: true))
        print(theAvatar.summarize(locMap: enkaDB.locTable, useMarkDown: false))
    }
}
