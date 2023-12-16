//
//  WidgetError.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/12/16.
//

import Foundation

enum WidgetError: CustomLocalizedStringResourceConvertible, LocalizedError {
    case accountSelectNeeded
    case noAccountFound

    // MARK: Internal

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .accountSelectNeeded:
            "widgetError.accountSelectNeeded"
        case .noAccountFound:
            "widgetError.noAccountFound"
        }
    }

    var errorDescription: String? {
        String(localized: localizedStringResource)
    }
}
