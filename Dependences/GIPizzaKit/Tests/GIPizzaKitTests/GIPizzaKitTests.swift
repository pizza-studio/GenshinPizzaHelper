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
}
