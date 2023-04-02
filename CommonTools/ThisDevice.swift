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

    public static var isHDScreenRatio: Bool {
        let screenSize = UIScreen.main.bounds.size
        let big = max(screenSize.width, screenSize.height)
        let small = min(screenSize.width, screenSize.height)
        return (1.76 ... 1.78).contains(big / small)
    }

    public static var useAdaptiveSpacing: Bool {
        (ThisDevice.notchType != .none || ThisDevice.isPad) &&
            AppConfig.adaptiveSpacingInCharacterView
    }

    /// 检测荧幕解析度是否为 iPhone 5 / 5c / 5s / SE Gen1 / iPod Touch 7th Gen 的最大荧幕解析度。
    /// 如果是 iPhone SE2 / SE3 / 6 / 7 / 8 且开启了荧幕放大模式的话，也会用到这个解析度。
    /// 不考虑 4:3 荧幕的机种（iPhone 4s 为止的机种）。
    public static var isSmallestHDScreenPhone: Bool {
        // 仅列出至少有支援 iOS 14 的机种。
        guard !["iPhone8,4", "iPod9,1"].contains(UIDevice.modelIdentifier)
        else {
            return true
        }
        let screenSize = UIScreen.main.bounds
        return min(screenSize.width, screenSize.height) < 375
    }

    public static var scaleRatioCompatible: CGFloat {
        if ThisDevice.isPad, useAdaptiveSpacing {
            return 1
        }
        let bounds = UIScreen.main.bounds
        let smallestDimension = min(bounds.width, bounds.height)
        return smallestDimension / (idiom == .pad ? 667 : 375)
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
