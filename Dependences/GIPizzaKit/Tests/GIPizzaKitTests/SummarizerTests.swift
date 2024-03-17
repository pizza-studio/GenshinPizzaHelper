@testable import GIPizzaKit
import XCTest

final class SummarizerTests: XCTestCase {
    let mapEnkaChar: Enka.Sputnik.CharMap = {
        try! JSONDecoder().decode(
            Enka.Sputnik.CharMap.self, from: Data(
                contentsOf: Bundle.module.url(forResource: "characters", withExtension: "json")!
            )
        )
    }()

    let mapEnkaLoc: Enka.Sputnik.CharLoc = {
        try! JSONDecoder().decode(
            Enka.CharacterLoc.self, from: Data(
                contentsOf: Bundle.module.url(forResource: "loc", withExtension: "json")!
            )
        )["zh-CN"]!
    }()

    /// 测试本地化
    func testAvatarInitiation() throws {
        let theAvatarRaw = try? JSONDecoder()
            .decode(Enka.PlayerDetailFetchModel.AvatarInfo.self, from: jsnYukuakiAvatar.data(using: .utf8) ?? .init([]))
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
