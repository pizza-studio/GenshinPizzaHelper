//
//  WKWebViewExtension.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2023/10/7.
//

import Foundation
import WebKit

public class OPWebView: WKWebView {
    // MARK: Lifecycle

    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: Self.mobileConfig)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    static let mobileConfig: WKWebViewConfiguration = {
        let result = WKWebViewConfiguration()
        let pref = WKWebpagePreferences()
        pref.preferredContentMode = .mobile
        result.defaultWebpagePreferences = pref
        return result
    }()
}
