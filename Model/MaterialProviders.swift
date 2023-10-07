//
//  MaterialProviders.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/24.
//  提供今日材料信息的工具类

import Defaults
import Foundation
import HBMihoyoAPI

// MARK: - WeaponOrTalentMaterial

struct WeaponOrTalentMaterial: Equatable {
    struct RelatedItem {
        // MARK: Lifecycle

        init(imageString: String, nameToLocalize: String) {
            self.imageString = imageString
            self.nameToLocalize = nameToLocalize
            self.weapon = nil
            self.character = nil
        }

        init(character asset: CharacterAsset) {
            self.imageString = asset.frontPhotoFileName
            self.nameToLocalize = asset.localized
            self.weapon = nil
            self.character = asset
        }

        init(weapon asset: WeaponAsset) {
            self.imageString = asset.fileName
            self.nameToLocalize = asset.localized
            self.weapon = asset
            self.character = nil
        }

        init?(asset: DailyMaterialConsumer) {
            if let asset = asset as? CharacterAsset {
                self.imageString = asset.frontPhotoFileName
                self.nameToLocalize = asset.localized
                self.weapon = nil
                self.character = asset
            } else if let asset = asset as? WeaponAsset {
                self.imageString = asset.fileName
                self.nameToLocalize = asset.localized
                self.weapon = asset
                self.character = nil
            } else {
                return nil
            }
        }

        // MARK: Internal

        let imageString: String
        let nameToLocalize: String
        let weapon: WeaponAsset?
        let character: CharacterAsset?

        var displayName: String {
            nameToLocalize.localizedWithFix
        }
    }

    let imageString: String
    let nameToLocalize: String
    let weekday: MaterialWeekday
    var relatedItem: [RelatedItem] = []

    var displayName: String {
        nameToLocalize.localizedWithFix
    }

    static func == (
        lhs: WeaponOrTalentMaterial,
        rhs: WeaponOrTalentMaterial
    )
        -> Bool {
        lhs.imageString == rhs.imageString
    }
}

// MARK: - WeaponMaterialProvider

struct WeaponMaterialProvider {
    var weekday: MaterialWeekday = .today()

    var todaysMaterials: [WeaponOrTalentMaterial] {
        WeaponOrTalentMaterial.allWeaponMaterialsOf(weekday: weekday)
    }
}

// MARK: - TalentMaterialProvider

struct TalentMaterialProvider {
    var weekday: MaterialWeekday = .today()

    var todaysMaterials: [WeaponOrTalentMaterial] {
        WeaponOrTalentMaterial.allTalentMaterialsOf(weekday: weekday)
    }
}

// MARK: - MaterialWeekday

enum MaterialWeekday: CaseIterable {
    case mondayAndThursday
    case tuesdayAndFriday
    case wednesdayAndSaturday
    case sunday

    // MARK: Internal

    static func today() -> Self {
        var calendar = Calendar.current
        calendar.timeZone = (Server(rawValue: Defaults[.defaultServer]) ?? Server.asia).timeZone()
        let isTimePast4am: Bool = Date() > calendar
            .date(bySettingHour: 4, minute: 0, second: 0, of: Date())!
        let todayWeekDayNum = calendar.dateComponents([.weekday], from: Date())
            .weekday!
        let weekdayNum = isTimePast4am ? todayWeekDayNum : (todayWeekDayNum - 1)
        switch weekdayNum {
        case 1:
            return .sunday
        case 2, 5:
            return .mondayAndThursday
        case 3, 6:
            return .tuesdayAndFriday
        case 0, 4, 7:
            return .wednesdayAndSaturday
        default:
            return .sunday
        }
    }

    func tomorrow() -> Self {
        switch self {
        case .mondayAndThursday:
            return .tuesdayAndFriday
        case .tuesdayAndFriday:
            return .wednesdayAndSaturday
        case .wednesdayAndSaturday:
            return .mondayAndThursday
        case .sunday:
            return .mondayAndThursday
        }
    }

    func describe() -> String {
        switch self {
        case .mondayAndThursday:
            return "week.MR".localized
        case .tuesdayAndFriday:
            return "week.TF".localized
        case .wednesdayAndSaturday:
            return "week.WS".localized
        case .sunday:
            return "week.sunday".localized
        }
    }
}

extension CharacterAsset {
    var asMaterialRelatedItem: WeaponOrTalentMaterial.RelatedItem {
        .init(character: self)
    }
}

extension WeaponAsset {
    var asMaterialRelatedItem: WeaponOrTalentMaterial.RelatedItem {
        .init(weapon: self)
    }
}
