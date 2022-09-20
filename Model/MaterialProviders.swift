//
//  MaterialProviders.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/24.
//  提供今日材料信息的工具类

import Foundation

struct WeaponMaterial {
    let imageString: String
    let localizedName: String
    let weekday: MaterialWeekday

    init(imageString: String, localizedName: String, weekday: MaterialWeekday) {
        self.imageString = imageString
        let localizedString = NSLocalizedString(localizedName, comment: "weapon name")
        self.localizedName = String(format: localizedString)
        self.weekday = weekday
    }
}

struct WeaponMaterialProvider {
    var weekday: MaterialWeekday = .today()

    var todaysMaterials: [WeaponMaterial] {
        WeaponMaterial.allMaterialsOf(weekday: weekday)
    }
}

struct TalentMaterial {
    let imageString: String
    let localizedName: String
    let weekday: MaterialWeekday

    init(imageString: String, localizedName: String, weekday: MaterialWeekday) {
        self.imageString = imageString
        let localizedString = NSLocalizedString(localizedName, comment: "talent material name")
        self.localizedName = String(format: localizedString)
        self.weekday = weekday
    }
}

struct TalentMaterialProvider {
    var weekday: MaterialWeekday = .today()

    var todaysMaterials: [TalentMaterial] {
        return TalentMaterial.allMaterialsOf(weekday: weekday)
    }

    var todaysMaterialImageString: [String] {
        todaysMaterials.map { $0.imageString }
    }
    var todaysMaterialName: [String] {
        todaysMaterials.map { $0.localizedName }
    }
}

enum MaterialWeekday {
    case mondayAndThursday
    case tuesdayAndFriday
    case wednesdayAndSaturday
    case sunday

    static func today() -> Self {
        let isTimePast4am: Bool = Date() > Calendar.current.date(bySettingHour: 4, minute: 0, second: 0, of: Date())!
        let todayWeekDayNum = Calendar.current.dateComponents([.weekday], from: Date()).weekday!
        let weekdayNum = isTimePast4am ? todayWeekDayNum : (todayWeekDayNum - 1)
        switch weekdayNum {
        case 1:
            return .sunday
        case 2, 5:
            return .mondayAndThursday
        case 3, 6:
            return .tuesdayAndFriday
        case 4, 7, 0:
            return .wednesdayAndSaturday
        default:
            return .sunday
        }
    }
}
