//
//  GetCookieWebView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/16.
//  获取Cookie的网页View

import HoYoKit
import SafariServices
import SwiftUI
import WebKit

// MARK: - GetCookieWebView

struct GetCookieWebView: View {
    @Binding
    var isShown: Bool

    @Binding
    var cookie: String!

    let region: Region

    var dataStore: WKWebsiteDataStore = .default()

    var body: some View {
        NavigationStack {
            CookieGetterWebView(
                url: getURL(region: region),
                dataStore: dataStore,
                httpHeaderFields: getHTTPHeaderFields(region: region)
            )
            .navigationTitle("account.login.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
                        Task(priority: .userInitiated) {
                            await getCookieFromDataStore()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("sys.cancel") {
                        isShown.toggle()
                    }
                }
            }
        }
    }

    @MainActor
    func getCookieFromDataStore() async {
        defer { isShown.toggle() }
        cookie = ""
        let cookies = await dataStore.httpCookieStore.allCookies()

        func getFromCookies(_ fieldName: String) -> String? {
            cookies.first(where: { $0.name == fieldName })?.value
        }

        switch region {
        case .mainlandChina:
            let loginTicket = getFromCookies("login_ticket") ?? ""
            let loginUid = getFromCookies("login_uid") ?? ""
            let multiToken = try? await MiHoYoAPI.getMultiTokenByLoginTicket(
                loginTicket: loginTicket,
                loginUid: loginUid
            )
            if let multiToken = multiToken {
                cookie += "stuid=" + loginUid + "; "
                cookie += "stoken=" + multiToken.stoken + "; "
                cookie += "ltuid=" + loginUid + "; "
                cookie += "ltoken=" + multiToken.ltoken + "; "
            }
        case .global:
            cookies.forEach {
                cookie += "\($0.name)=\($0.value); "
            }
        }
    }
}

// MARK: - CookieGetterWebView

struct CookieGetterWebView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        // MARK: Lifecycle

        init(_ parent: CookieGetterWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: CookieGetterWebView

        func webView(
            _ webView: WKWebView,
            didFinish _: WKNavigation!
        ) {
            let jsonScript = """
            let timer = setInterval(() => {
            var m = document.getElementById("driver-page-overlay");
            m.parentNode.removeChild(m);
            }, 300);
            setTimeout(() => {clearInterval(timer);timer = null}, 10000);
            """
            webView.evaluateJavaScript(jsonScript)
        }
    }

    var url: String = ""
    let dataStore: WKWebsiteDataStore
    let httpHeaderFields: [String: String]

    func makeUIView(context: Context) -> OPWebView {
        guard let url = URL(string: url)
        else {
            return OPWebView()
        }
        dataStore
            .fetchDataRecords(
                ofTypes: WKWebsiteDataStore
                    .allWebsiteDataTypes()
            ) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default()
                        .removeData(
                            ofTypes: record.dataTypes,
                            for: [record],
                            completionHandler: {}
                        )
                    #if DEBUG
                    print("WKWebsiteDataStore record deleted:", record)
                    #endif
                }
            }
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        let timeoutInterval: TimeInterval = 10
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: timeoutInterval
        )
        request.allHTTPHeaderFields = httpHeaderFields
        let webview = OPWebView()
        webview.configuration.websiteDataStore = dataStore
        webview.navigationDelegate = context.coordinator
        webview.load(request)
        return webview
    }

    func updateUIView(_ uiView: OPWebView, context _: Context) {
        if let url = URL(string: url) {
            let timeoutInterval: TimeInterval = 10
            var request = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: timeoutInterval
            )
            request.httpShouldHandleCookies = false
            request.allHTTPHeaderFields = httpHeaderFields
            print(request.description)
            uiView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension CookieGetterWebView {}

private func getURL(region: Region) -> String {
    switch region {
    case .mainlandChina:
        return "https://user.mihoyo.com/#/login/captcha"
    case .global:
        return "https://www.hoyolab.com/"
    }
}

private func getHTTPHeaderFields(region: Region) -> [String: String] {
    switch region {
    case .mainlandChina:
        return [
            "Accept": """
            text/html,application/xhtml+xml,application/xml;q=0.9,\
            image/webp,image/apng,*/*;q=0.8,\
            application/signed-exchange;v=b3;q=0.9
            """,
            "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
            "Connection": "keep-alive",
            "Accept-Encoding": "gzip, deflate, br",
            "User-Agent": """
            Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) \
            AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 \
            Safari/604.1
            """,
            "cache-control": "max-age=0",
        ]
    case .global:
        return [
            "accept": """
            text/html,application/xhtml+xml,\
            application/xml;q=0.9,\
            image/webp,image/apng,*/*;q=0.8,\
            application/signed-exchange;v=b3;q=0.9
            """,
            "accept-language": "zh-CN,zh-Hans;q=0.9",
            "accept-encoding": "gzip, deflate, br",
            "user-agent": """
            Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) \
            AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 \
            Safari/604.1
            """,
            "cache-control": "max-age=0",
        ]
    }
}

// MARK: - QRCodeGetCookieView

struct QRCodeGetCookieView: View {
    @Environment(\.dismiss)
    private var dismiss

    @State
    private var qrCodeAndTicket: (qrCode: UIImage, ticket: String)?
    @State
    private var taskId: UUID = .init()
    @State
    private var error: Error?

    @Binding
    var cookie: String!

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let qrCodeAndTicket {
                        Image(uiImage: qrCodeAndTicket.qrCode)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } else if let error {
                        Label {
                            Text(error.localizedDescription)
                        } icon: {
                            Image(systemSymbol: .exclamationmarkCircle)
                                .foregroundStyle(.red)
                        }
                        Button("sys.retry") {
                            taskId = UUID()
                        }
                    } else {
                        ProgressView()
                    }
                } footer: {
                    Text("Please take a screenshot of the qr code and scan it in miyoushe")
                }
            }
            .navigationTitle("account.login.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("sys.cancel") {
                        dismiss()
                    }
                }
            }
        }
        .task(id: taskId) {
            print("TaskID: \(taskId)")
            do {
                qrCodeAndTicket = try await MiHoYoAPI.generateLoginQRCode(deviceId: taskId)
                QRCodeCheckLoop: while !Task.isCancelled {
                    let status = try await MiHoYoAPI.queryQRCodeStatus(
                        deviceId: taskId,
                        ticket: qrCodeAndTicket!.ticket
                    )

                    print("QRCodeStatus: \(status)")

                    if case let .confirmed(accountId: accountId, token: gameToken) = status {
                        let stoken = try await MiHoYoAPI.gameToken2StokenV2(
                            accountId: accountId,
                            gameToken: gameToken
                        ).stoken
                        print("SToken: \(stoken)")

                        let ltoken = try await MiHoYoAPI.stoken2LTokenV1(
                            accountId: accountId,
                            stoken: stoken
                        ).ltoken
                        print("LToken: \(ltoken)")

                        var cookie = ""
                        cookie += "stuid=" + accountId + "; "
                        cookie += "stoken=" + stoken + "; "
                        cookie += "ltuid=" + accountId + "; "
                        cookie += "ltoken=" + ltoken + "; "
                        self.cookie = cookie

                        dismiss()

                        break QRCodeCheckLoop
                    }

                    try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 seconds
                }
            } catch {
                self.error = error
            }
        }
    }
}
