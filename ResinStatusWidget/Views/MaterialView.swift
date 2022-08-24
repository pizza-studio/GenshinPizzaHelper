//
//  MaterialView.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/24.
//

import SwiftUI

struct MaterialView: View {
    var body: some View {
        Text("")
    }
}

struct TalentMaterialProvider {
    private let weekday: Weekday = .today

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
        let freedom: TalentMaterial = .init(imageString: "talent.Freedom", localizedName: "自由")
        let resistance: TalentMaterial = .init(imageString: "talent.Resistance", localizedName: "抗争")
        let ballad: TalentMaterial = .init(imageString: "talent.Ballad", localizedName: "诗文")

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
        let prosperity: TalentMaterial = .init(imageString: "talent.Prosperity", localizedName: "繁荣")
        let diligence: TalentMaterial = .init(imageString: "talent.Diligence", localizedName: "勤劳")
        let gold: TalentMaterial = .init(imageString: "talent.Gold", localizedName: "黄金")

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
        let transience: TalentMaterial = .init(imageString: "talent.Transience", localizedName: "浮世")
        let elegance: TalentMaterial = .init(imageString: "talent.Elegance", localizedName: "风雅")
        let light: TalentMaterial = .init(imageString: "talent.Light", localizedName: "天光")

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
        let admonition: TalentMaterial = .init(imageString: "talent.Admonition", localizedName: "诤言")
        let ingenuity: TalentMaterial = .init(imageString: "talent.Ingenuity", localizedName: "巧思")
        let praxis: TalentMaterial = .init(imageString: "talent.Praxis", localizedName: "笃行")

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
    }

    private enum Weekday {
        case mondayAndThursday
        case tuesdayAndFriday
        case wednesdayAndSaturday
        case sunday

        static var today: Self {
            let weekdayNum = Calendar.current.dateComponents([.weekday], from: Date()).weekday!
            switch weekdayNum {
            case 1:
                return .sunday
            case 2, 5:
                return .mondayAndThursday
            case 3, 6:
                return .tuesdayAndFriday
            case 4, 7:
                return .wednesdayAndSaturday
            default:
                return .sunday
            }
        }
    }

}

