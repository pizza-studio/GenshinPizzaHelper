@testable import GIPizzaKit
import XCTest

final class GIPizzaKitTests: XCTestCase {
    /// 测试本地化
    func testAssetEnumLocalization() throws {
        // 测试角色
        let char = CharacterAsset.Hotaru
        print(char.localized)
        assert(char.localized.first != "$")
        // 测试每日材料
        let material = DailyMaterialAsset.talentFreedom
        print(material.localized)
        assert(material.localized.first != "$")
        // 测试名片
        let namecard = NameCard.UI_NameCardPic_Yelan_P
        print(namecard.localized)
        assert(namecard.localized.first != "$")
        // 测试武器
        let weapon = WeaponAsset.SplendorOfStillWaters
        print(weapon.localized)
        assert(namecard.localized.first != "$")
    }

    func testPFPQuery() throws {
        let x = Enka.queryProfilePictureURL(pfpID: "100050")
        XCTAssertNotNil(x)
        if let x = x {
            print(x)
        }
    }

    func testCharacterArtifactRatingModelValidity() throws {
        // 这个测试用来检查是否有角色的圣遗物评分数据出现了重复的 key。
        // Swift 的编译过程不会阻止这种情况，所以这种情况会导致 runtime error。
        // 于是只能写这么个单元测试。
        _ = CharacterAsset.allCases.map { $0.getArtifactRatingModel() }
    }
}
