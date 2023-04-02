//
//  ThisDevice.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/7.
//

import SwiftUI

// MARK: - ThisDevice

enum ThisDevice {
    // MARK: Public

    public static var isMac: Bool {
        #if targetEnvironment(simulator)
            return false
        #else
            if #available(macOS 10.15, *) {
                return true
            }
            return false
        #endif
    }

    public static var isPad: Bool {
        idiom == .pad && !isMac
    }

    public static var isScreenLandScape: Bool {
        guard let window = UIApplication.shared.windows
            .filter({ $0.isKeyWindow }).first else { return false }
        let filtered = window.safeAreaInsets.allParamters.filter { $0 > 0 }
        return filtered.count == 3
    }

    public static var idiom: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }

    public static var isNotchedPhone: Bool {
        let screenSize = UIScreen.main.bounds.size
        let big = max(screenSize.width, screenSize.height)
        let small = min(screenSize.width, screenSize.height)
        return (big / small) >= 1.8
    }

    public static var useAdaptiveSpacing: Bool {
        (ThisDevice.notchType != .none || ThisDevice.isPad) &&
            AppConfig.adaptiveSpacingInCharacterView
    }

    // MARK: Internal

    enum NotchType {
        case normalNotch
        case dynamicIsland
        case none
    }

    static var notchType: NotchType {
        guard hasNotchOrDynamicIsland else { return .none }
        guard hasDynamicIsland else { return .normalNotch }
        return .dynamicIsland
    }

    // MARK: Private

    private static var hasDynamicIsland: Bool {
        guard let window = UIApplication.shared.windows
            .filter({ $0.isKeyWindow }).first else { return false }
        let filtered = window.safeAreaInsets.allParamters.filter { $0 >= 59 }
        return filtered.count == 1
    }

    private static var hasNotchOrDynamicIsland: Bool {
        guard let window = UIApplication.shared.windows
            .filter({ $0.isKeyWindow }).first else { return false }
        let filtered = window.safeAreaInsets.allParamters.filter { $0 >= 44 }
        return filtered.count == 1
    }
}

extension UIEdgeInsets {
    fileprivate var allParamters: [CGFloat] {
        [bottom, top, left, right]
    }
}
