//
//  MaterialProviders.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/24.
//  提供今日材料信息的工具类

import Foundation

struct WeaponMaterialProvider {
    var weekday: MaterialWeekday = .today()

    var todaysMaterials: [WeaponMaterial] {
        var materials: [WeaponMaterial] = .init()
        materials.append(contentsOf: todayMondstadtMaterials)
        materials.append(contentsOf: todayLiyueMaterials)
        materials.append(contentsOf: todayInazumaMaterials)
        materials.append(contentsOf: todaySumeruMaterials)
        return materials
    }

    var todaysMaterialImageString: [String] {
        todaysMaterials.map { $0.imageString }
    }
    var todaysMaterialName: [String] {
        todaysMaterials.map { $0.localizedName }
    }

    var todayMondstadtMaterials: [WeaponMaterial] {
        let decarabian: WeaponMaterial = .init(imageString: "weapon.Decarabian", localizedName: "「高塔孤王」")
        let borealWolf: WeaponMaterial = .init(imageString: "weapon.BorealWolf", localizedName: "「凛风奔狼」")
        let dandelionGladiator: WeaponMaterial = .init(imageString: "weapon.DandelionGladiator", localizedName: "「狮牙斗士」")

        switch weekday {
        case .mondayAndThursday:
            return [decarabian]
        case .tuesdayAndFriday:
            return [borealWolf]
        case .wednesdayAndSaturday:
            return [dandelionGladiator]
        case .sunday:
            return [decarabian, borealWolf, dandelionGladiator]
        }
    }

    var todayLiyueMaterials: [WeaponMaterial] {
        let guyun: WeaponMaterial = .init(imageString: "weapon.Guyun", localizedName: "「孤云寒林」")
        let mistVeiled: WeaponMaterial = .init(imageString: "weapon.MistVeiled", localizedName: "「雾海云间」")
        let aerosiderite: WeaponMaterial = .init(imageString: "weapon.Aerosiderite", localizedName: "「漆黑陨铁」")

        switch weekday {
        case .mondayAndThursday:
            return [guyun]
        case .tuesdayAndFriday:
            return [mistVeiled]
        case .wednesdayAndSaturday:
            return [aerosiderite]
        case .sunday:
            return [guyun, mistVeiled, aerosiderite]
        }
    }

    var todayInazumaMaterials: [WeaponMaterial] {
        let distantSea: WeaponMaterial = .init(imageString: "weapon.DistantSea", localizedName: "「远海夷地」")
        let narukami: WeaponMaterial = .init(imageString: "weapon.Narukami", localizedName: "「鸣神御灵」")
        let kijin: WeaponMaterial = .init(imageString: "weapon.Kijin", localizedName: "「今昔剧画」")

        switch weekday {
        case .mondayAndThursday:
            return [distantSea]
        case .tuesdayAndFriday:
            return [narukami]
        case .wednesdayAndSaturday:
            return [kijin]
        case .sunday:
            return [distantSea, narukami, kijin]
        }
    }

    var todaySumeruMaterials: [WeaponMaterial] {
        let forestDew: WeaponMaterial = .init(imageString: "weapon.ForestDew", localizedName: "「谧林涓露」")
        let oasisGarden: WeaponMaterial = .init(imageString: "weapon.OasisGarden", localizedName: "「绿洲花园」")
        let scorchingMight: WeaponMaterial = .init(imageString: "weapon.ScorchingMight", localizedName: "「烈日威权」")

        switch weekday {
        case .mondayAndThursday:
            return [forestDew]
        case .tuesdayAndFriday:
            return [oasisGarden]
        case .wednesdayAndSaturday:
            return [scorchingMight]
        case .sunday:
            return [forestDew, oasisGarden, scorchingMight]
        }
    }

    struct WeaponMaterial {
        let imageString: String
        let localizedName: String

        init(imageString: String, localizedName: String) {
            self.imageString = imageString
            let localizedString = NSLocalizedString(localizedName, comment: "weapon name")
            self.localizedName = String(format: localizedString)
        }
    }

}

struct TalentMaterialProvider {
    var weekday: MaterialWeekday = .today()

    var todaysMaterials: [TalentMaterial] {
        var materials: [TalentMaterial] = .init()
        materials.append(contentsOf: todayMondstadtMaterials)
        materials.append(contentsOf: todayLiyueMaterials)
        materials.append(contentsOf: todayInazumaMaterials)
        materials.append(contentsOf: todaySumeruMaterials)
        return materials
    }

    var todaysMaterialImageString: [String] {
        todaysMaterials.map { $0.imageString }
    }
    var todaysMaterialName: [String] {
        todaysMaterials.map { $0.localizedName }
    }

    var todayMondstadtMaterials: [TalentMaterial] {
        let freedom: TalentMaterial = .init(imageString: "talent.Freedom", localizedName: "「自由」")
        let resistance: TalentMaterial = .init(imageString: "talent.Resistance", localizedName: "「抗争」")
        let ballad: TalentMaterial = .init(imageString: "talent.Ballad", localizedName: "「诗文」")

        switch weekday {
        case .mondayAndThursday:
            return [freedom]
        case .tuesdayAndFriday:
            return [resistance]
        case .wednesdayAndSaturday:
            return [ballad]
        case .sunday:
            return [freedom, resistance, ballad]
        }
    }

    var todayLiyueMaterials: [TalentMaterial] {
        let prosperity: TalentMaterial = .init(imageString: "talent.Prosperity", localizedName: "「繁荣」")
        let diligence: TalentMaterial = .init(imageString: "talent.Diligence", localizedName: "「勤劳」")
        let gold: TalentMaterial = .init(imageString: "talent.Gold", localizedName: "「黄金」")

        switch weekday {
        case .mondayAndThursday:
            return [prosperity]
        case .tuesdayAndFriday:
            return [diligence]
        case .wednesdayAndSaturday:
            return [gold]
        case .sunday:
            return [prosperity, diligence, gold]
        }
    }

    var todayInazumaMaterials: [TalentMaterial] {
        let transience: TalentMaterial = .init(imageString: "talent.Transience", localizedName: "「浮世」")
        let elegance: TalentMaterial = .init(imageString: "talent.Elegance", localizedName: "「风雅」")
        let light: TalentMaterial = .init(imageString: "talent.Light", localizedName: "「天光」")

        switch weekday {
        case .mondayAndThursday:
            return [transience]
        case .tuesdayAndFriday:
            return [elegance]
        case .wednesdayAndSaturday:
            return [light]
        case .sunday:
            return [transience, elegance, light]
        }
    }

    var todaySumeruMaterials: [TalentMaterial] {
        let admonition: TalentMaterial = .init(imageString: "talent.Admonition", localizedName: "「诤言」")
        let ingenuity: TalentMaterial = .init(imageString: "talent.Ingenuity", localizedName: "「巧思」")
        let praxis: TalentMaterial = .init(imageString: "talent.Praxis", localizedName: "「笃行」")

        switch weekday {
        case .mondayAndThursday:
            return [admonition]
        case .tuesdayAndFriday:
            return [ingenuity]
        case .wednesdayAndSaturday:
            return [praxis]
        case .sunday:
            return [admonition, ingenuity, praxis]
        }
    }

    struct TalentMaterial {
        let imageString: String
        let localizedName: String

        init(imageString: String, localizedName: String) {
            self.imageString = imageString
            let localizedString = NSLocalizedString(localizedName, comment: "talent material name")
            self.localizedName = String(format: localizedString)
        }
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
