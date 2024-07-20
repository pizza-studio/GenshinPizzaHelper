@testable import GIPizzaKit
import XCTest

final class SummarizerTests: XCTestCase {
    let mapEnkaChar: EnkaGI.Sputnik.CharMap = {
        try! JSONDecoder().decode(
            EnkaGI.Sputnik.CharMap.self, from: Data(
                contentsOf: Bundle.module.url(forResource: "characters", withExtension: "json")!
            )
        )
    }()

    let mapEnkaLoc: EnkaGI.Sputnik.CharLoc = {
        try! JSONDecoder().decode(
            EnkaGI.CharacterLoc.self, from: Data(
                contentsOf: Bundle.module.url(forResource: "loc", withExtension: "json")!
            )
        )["ja"]!
    }()

    /// 测试本地化
    func testAvatarInitiation() throws {
        let theAvatarRaw = try? JSONDecoder()
            .decode(
                EnkaGI.PlayerDetailFetchModel.AvatarInfo.self,
                from: jsnYukuakiAvatar.data(using: .utf8) ?? .init([])
            )
        XCTAssertNotNil(theAvatarRaw)
        guard let theAvatarRaw = theAvatarRaw else { exit(1) }
        let theAvatar = PlayerDetail.Avatar(
            avatarInfo: theAvatarRaw,
            localizedDictionary: mapEnkaLoc,
            characterDictionary: mapEnkaChar,
            uid: "1145141919810"
        )
        XCTAssertNotNil(theAvatar)
        guard let theAvatar = theAvatar else { exit(1) }
        print(theAvatar.summarize(locMap: mapEnkaLoc, useMarkDown: true))
        print(theAvatar.summarize(locMap: mapEnkaLoc, useMarkDown: false))
    }
}
