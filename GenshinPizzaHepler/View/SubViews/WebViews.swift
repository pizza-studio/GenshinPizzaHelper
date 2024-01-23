//
//  SFSafariView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/10.
//  封装了使用OPWebView的各种网页

import Defaults
import HoYoKit
import SafariServices
import SwiftUI
import WebKit

// MARK: - SFSafariViewWrapper

struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<Self>
    )
        -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SFSafariViewWrapper>
    ) {}
}

// MARK: - WebBrowserView

struct WebBrowserView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        // MARK: Lifecycle

        init(_ parent: WebBrowserView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: WebBrowserView

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            webView.injectDarkModeAwareness()
        }
    }

    var url: String = ""

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> OPWebView {
        guard let url = URL(string: url)
        else {
            return OPWebView()
        }
        let request = URLRequest(url: url)
        let webview = OPWebView()
        webview.load(request)
        return webview
    }

    func updateUIView(_ uiView: OPWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

// MARK: - TeyvatMapWebView

struct TeyvatMapWebView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        // MARK: Lifecycle

        init(_ parent: TeyvatMapWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: TeyvatMapWebView

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            var js = ""
            js.append("let timer = setInterval(() => {")
            js
                .append(
                    "const bar = document.getElementsByClassName('mhy-bbs-app-header')[0];"
                )
            js
                .append(
                    "const hoyolabBar = document.getElementsByClassName('mhy-hoyolab-app-header')[0];"
                )
            js.append("bar?.parentNode.removeChild(bar);")
            js.append("hoyolabBar?.parentNode.removeChild(hoyolabBar);")
            js.append("}, 300);")
            js
                .append(
                    "setTimeout(() => {clearInterval(timer);timer = null}, 10000);"
                )
            webView.evaluateJavaScript(js)
        }
    }

    var region: Region

    func makeUIView(context: Context) -> OPWebView {
        guard let url = region.teyvatInteractiveMapURL
        else {
            return OPWebView()
        }
        let request = URLRequest(url: url)

        let webView = OPWebView()
        webView.configuration.userContentController.removeAllUserScripts() // 对提瓦特地图禁用自动 dark mode 支持。
        webView.navigationDelegate = context.coordinator
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: OPWebView, context: Context) {
        if let url = region.teyvatInteractiveMapURL {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - EventDetailWebView

struct EventDetailWebView: UIViewRepresentable {
    // MARK: Lifecycle

    init(banner: String, nameFull: String, content: String) {
        self.banner = banner
        self.nameFull = nameFull
        self.content = content
    }

    // MARK: Internal

    class Coordinator: NSObject, WKScriptMessageHandler, WKUIDelegate {
        // MARK: Lifecycle

        init(_ parent: EventDetailWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: EventDetailWebView

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            print("message: \(message.name)")
            switch message.name {
            case "getArticleInfoBeforeLoaded":
                if let articleData = try? JSONSerialization.data(
                    withJSONObject: parent.getArticleDic(),
                    options: JSONSerialization.WritingOptions.prettyPrinted
                ) {
                    let articleInfo = String(
                        data: articleData,
                        encoding: String.Encoding.utf8
                    )

                    let inputJS = "updateArticleInfo(\(articleInfo ?? ""))"
                    print(inputJS)
                    parent.webView.evaluateJavaScript(inputJS)
                }
            default:
                break
            }
        }
    }

    @Environment(\.colorScheme)
    var colorScheme
    let webView = OPWebView()
//    let htmlContent: String
    let banner: String
    let nameFull: String
    let content: String
    var articleDic = [
        // 主题颜色：亮色：""，暗色："bg-amberDark-500 text-amberHalfWhite"
        "themeClass": "",
        "banner": "",
        "nameFull": "",
        "description": "",
    ]

    static func dismantleUIView(_ uiView: OPWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController
            .removeScriptMessageHandler(forName: "getArticleInfoBeforeLoaded")
    }

    func makeUIView(context: Context) -> OPWebView {
        webView.configuration.userContentController.add(
            makeCoordinator(),
            name: "getArticleInfoBeforeLoaded"
        )
        return webView
    }

    func updateUIView(_ uiView: OPWebView, context: Context) {
        uiView.uiDelegate = context.coordinator
        if let startPageURL = Bundle.main.url(
            forResource: "article",
            withExtension: "html"
        ) {
            uiView.loadFileURL(
                startPageURL,
                allowingReadAccessTo: Bundle.main.bundleURL
            )
        }
    }

    func getArticleDic() -> [String: String] {
        if colorScheme == .dark {
            let articleDic = [
                "themeClass": "bg-amberDark-800 text-amberHalfWhite", // 主题颜色
                "banner": banner,
                "nameFull": nameFull,
                "description": content,
            ]
            return articleDic
        } else {
            let articleDic = [
                "themeClass": "", // 主题颜色
                "banner": banner,
                "nameFull": nameFull,
                "description": content,
            ]
            return articleDic
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - UserPolicyView

struct UserPolicyView: View {
    @Binding
    var sheet: ContentViewSheetType?

    var body: some View {
        NavigationStack {
            WebBrowserView(url: "https://gi.pizzastudio.org/static/policy.html")
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("app.disagree") {
                            exit(1)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("app.agree") {
                            Defaults[.isPolicyShown] = true
                            UserDefaults.opSuite.synchronize()
                            sheet = nil
                        }
                    }
                }
                .navigationTitle("settings.misc.EULA")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
