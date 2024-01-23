//
//  WKWebViewExtension.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2023/10/7.
//

import Foundation
import WebKit

// MARK: - OPWebView

public class OPWebView: WKWebView {
    // MARK: Lifecycle

    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: Self.makeMobileConfig())
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    static let jsForDarkmodeAwareness: String = {
        let cssString = "@media (prefers-color-scheme: dark) { body { background: #333; color: white; } }"
        let jsString =
            "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        return jsString
    }()

    static func makeMobileConfig() -> WKWebViewConfiguration {
        let userScript = WKUserScript(
            source: OPWebView.jsForDarkmodeAwareness,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)

        let result = WKWebViewConfiguration()
        let pagePref = WKWebpagePreferences()
        let viewPref = WKPreferences()
        viewPref.isTextInteractionEnabled = true
        pagePref.preferredContentMode = .mobile
        result.defaultWebpagePreferences = pagePref
        result.preferences = viewPref
        result.userContentController = userContentController
        return result
    }
}

extension WKWebView {
    public func injectDarkModeAwareness() {
        let cssString = "@media (prefers-color-scheme: dark) { body { background: #333; color: white; } }"
        let jsString =
            "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        evaluateJavaScript(jsString)
    }
}
