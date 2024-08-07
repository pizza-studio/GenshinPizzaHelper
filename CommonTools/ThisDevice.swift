//
//  ThisDevice.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/7.
//

import Defaults
import SwiftUI

// MARK: - ThisDevice

enum ThisDevice {
    // MARK: Public

    public static var basicWindowSize: CGSize {
        var result = CGSize(
            // width: 375,
            // height: useAdaptiveSpacing ? 812 : 667
            // 新的基准尺寸是原有的 1.66 倍：620x1344 与 620x1104。
            width: 620 + 2,
            height: useAdaptiveSpacing ? 1344 + 2 : 1104 + 2
        )
        if OS.isCatalyst {
            result.height += useAdaptiveSpacing ? 90 : 150
        }
        return result
    }

    public static var isScreenLandScape: Bool {
        guard let window = getKeyWindow() else { return false }
        let filtered = window.safeAreaInsets.allParamters.filter { $0 > 0 }
        return filtered.count == 3
    }

    public static var isHDScreenRatio: Bool {
        let screenSize = UIScreen.main.bounds.size
        let big = max(screenSize.width, screenSize.height)
        let small = min(screenSize.width, screenSize.height)
        return (1.76 ... 1.78).contains(big / small)
    }

    public static var isHDPhoneOrPodTouch: Bool {
        isHDScreenRatio && OS.type == .iPhoneOS
    }

    public static var useAdaptiveSpacing: Bool {
        (ThisDevice.notchType != .none || OS.type != .iPhoneOS) &&
            Defaults[.adaptiveSpacingInCharacterView]
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

    public static var isSmallestSlideOverWindowWidth: Bool {
        guard let window = getKeyWindow() else { return Self.isSmallestHDScreenPhone }
        return min(window.frame.width, window.frame.height) < 375
    }

    public static var scaleRatioCompatible: CGFloat {
        guard let window = getKeyWindow() else { return 1 }
        let windowSize = window.bounds.size
        // 对哀凤优先使用宽度适配，没准哪天哀凤长得跟法棍面包似的也说不定。
        var result = windowSize.width / basicWindowSize.width
        let zoomedSize = CGSize(
            width: basicWindowSize.width * result,
            height: basicWindowSize.height * result
        )
        let compatible = CGRect(origin: .zero, size: windowSize)
            .contains(CGRect(origin: .zero, size: zoomedSize))
        if !compatible {
            result = windowSize.height / basicWindowSize.height
        }
        return result
    }

    public static var isThinnestSplitOnPad: Bool {
        guard OS.type == .iPadOS, isSplitOrSlideOver else { return false }
        guard let window = getKeyWindow() else { return false }
        let windowSize = window.frame.size
        let big = max(windowSize.width, windowSize.height)
        let small = min(windowSize.width, windowSize.height)
        return (2.2 ... 4).contains(big / small)
    }

    public static var isWidestSplitOnPad: Bool {
        guard OS.type == .iPadOS, isSplitOrSlideOver else { return false }
        guard let window = getKeyWindow() else { return false }
        let windowSize = window.frame.size
        let big = max(windowSize.width, windowSize.height)
        let small = min(windowSize.width, windowSize.height)
        return (1 ... 1.05).contains(big / small)
    }

    public static var isSplitOrSlideOver: Bool {
        guard let window = getKeyWindow() else { return false }
        return window.frame.width != window.screen.bounds.width
    }

    public static var isRunningInFullScreen: Bool {
        guard let window = getKeyWindow() else { return true }
        let screenSize = UIScreen.main.bounds.size
        let appSize = window.bounds.size
        let compatibleA = CGRectEqualToRect(
            CGRect(origin: .zero, size: screenSize),
            CGRect(origin: .zero, size: appSize)
        )
        let appSizeFlipped = CGSize(
            width: appSize.height,
            height: appSize.width
        )
        let compatibleB = CGRectEqualToRect(
            CGRect(origin: .zero, size: screenSize),
            CGRect(origin: .zero, size: appSizeFlipped)
        )
        return compatibleA || compatibleB
    }

    public static func getKeyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { scene -> UIWindow? in
                (scene as? UIWindowScene)?.keyWindow
            }
            .first
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
        guard let window = getKeyWindow() else { return false }
        let filtered = window.safeAreaInsets.allParamters.filter { $0 >= 59 }
        return filtered.count == 1
    }

    private static var hasNotchOrDynamicIsland: Bool {
        guard let window = getKeyWindow() else { return false }
        let filtered = window.safeAreaInsets.allParamters.filter { $0 >= 44 }
        return filtered.count == 1
    }
}

extension UIEdgeInsets {
    fileprivate var allParamters: [CGFloat] {
        [bottom, top, left, right]
    }
}

// MARK: - Globally-Observable Device Orientation for SwiftUI

// Ref: https://developer.apple.com/forums/thread/126878?answerId=654602022#654602022

import Combine

// MARK: - ThisDevice.DeviceOrientation

extension ThisDevice {
    final class DeviceOrientation: ObservableObject {
        // MARK: Lifecycle

        init() {
            self.orientation = UIDevice.current.orientation
                .isLandscape ? .landscape : .portrait
            self.listener = NotificationCenter.default
                .publisher(for: UIDevice.orientationDidChangeNotification)
                .compactMap { ($0.object as? UIDevice)?.orientation }
                .compactMap { deviceOrientation -> Orientation? in
                    if deviceOrientation.isPortrait {
                        return .portrait
                    } else if deviceOrientation.isLandscape {
                        return .landscape
                    } else {
                        return nil
                    }
                }
                .assign(to: \.orientation, on: self)
        }

        deinit {
            listener?.cancel()
        }

        // MARK: Internal

        enum Orientation {
            case portrait
            case landscape
        }

        @Published
        var orientation: Orientation

        // MARK: Private

        private var listener: AnyCancellable?
    }
}
