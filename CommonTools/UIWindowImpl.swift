//
//  UIWindowImpl.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2024/2/19.
//

import Dynamic
import Foundation
import UIKit

extension UIWindow {
    public var nsWindow: NSObject? {
        var nsWindow = Dynamic.NSApplication.sharedApplication.delegate.hostWindowForUIWindow(self)
        if #available(macOS 11, *) {
            nsWindow = nsWindow.attachedWindow
        }
        return nsWindow.asObject
    }

    public var scaleFactor: CGFloat {
        get {
            Dynamic(rootViewController?.view.window).contentView
                .subviews.firstObject.scaleFactor ?? 1.0
        }
        set {
            Dynamic(rootViewController?.view.window).contentView
                .subviews.firstObject.scaleFactor = newValue
        }
    }
}
