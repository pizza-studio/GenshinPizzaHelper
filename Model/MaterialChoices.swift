//
//  MaterialChoices.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/20.
//

import Foundation
import GIPizzaKit

extension WeaponOrTalentMaterial {
    // MARK: - Weapon Material choices

    // 所有材料
    static let allWeaponMaterials: [WeaponOrTalentMaterial] = DailyMaterialAsset.allCases.compactMap { asset in
        guard String(describing: asset).starts(with: "weapon") else { return nil }
        var weekday: MaterialWeekday = .sunday
        if let availableWeekday = asset.availableWeekDay {
            switch availableWeekday {
            case .MonThu:
                weekday = .mondayAndThursday
            case .TueFri:
                weekday = .tuesdayAndFriday
            case .WedSat:
                weekday = .wednesdayAndSaturday
            }
        }
        let relatedItem: [RelatedItem] = WeaponAsset.allCases.compactMap { weapon in
            guard weapon.dailyMaterial == asset else { return nil }
            return RelatedItem(weapon: weapon)
        }
        return WeaponOrTalentMaterial(
            imageString: asset.fileName,
            nameToLocalize: asset.localized,
            weekday: weekday,
            relatedItem: relatedItem
        )
    }

    static func allWeaponMaterialsOf(weekday: MaterialWeekday)
        -> [WeaponOrTalentMaterial] {
        allWeaponMaterials.filter { material in
            (material.weekday == weekday) || (weekday == .sunday)
        }
    }

    static let dumpedWeaponIconMap: [String: String] = {
        var mapOutput = [String: String]()
        allWeaponMaterials.forEach { theMaterial in
            theMaterial.relatedItem.forEach { theItem in
                mapOutput[theItem.nameToLocalize] = theItem.imageString
            }
        }
        return mapOutput
    }()

    // MARK: - Talent Material choices

    // 所有天赋材料
    static let allTalentMaterials: [WeaponOrTalentMaterial] = DailyMaterialAsset.allCases.compactMap { asset in
        guard String(describing: asset).starts(with: "talent") else { return nil }
        var weekday: MaterialWeekday = .sunday
        if let availableWeekday = asset.availableWeekDay {
            switch availableWeekday {
            case .MonThu:
                weekday = .mondayAndThursday
            case .TueFri:
                weekday = .tuesdayAndFriday
            case .WedSat:
                weekday = .wednesdayAndSaturday
            }
        }
        let relatedItem: [RelatedItem] = CharacterAsset.allCases.compactMap { character in
            guard character.dailyMaterial == asset else { return nil }
            return RelatedItem(character: character)
        }
        return WeaponOrTalentMaterial(
            imageString: asset.fileName,
            nameToLocalize: asset.localized,
            weekday: weekday,
            relatedItem: relatedItem
        )
    }

    static func allTalentMaterialsOf(weekday: MaterialWeekday)
        -> [WeaponOrTalentMaterial] {
        allTalentMaterials.filter { material in
            (material.weekday == weekday) || (weekday == .sunday)
        }
    }
}
