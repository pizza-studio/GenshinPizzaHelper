//
//  TestView.swift
//  原神披萨小助手
//
//  Created by 戴藏龙 on 2022/8/8.
//  测试连接部分的View

import HBMihoyoAPI
import SwiftUI
import WebKit

// MARK: - TestSectionView

struct TestSectionView: View {
    // MARK: Internal

    @EnvironmentObject
    var viewModel: ViewModel

    @Binding
    var connectStatus: ConnectStatus

    @Binding
    var uid: String
    @Binding
    var cookie: String
    @Binding
    var server: Server
    @Binding
    var deviceFingerPrint: String

    var body: some View {
        Section {
            Button(action: {
                connectStatus = .testing
            }) {
                HStack {
                    Text("测试连接")
                    Spacer()
                    switch connectStatus {
                    case .unknown:
                        Text("")
                    case .success:
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    case .fail:
                        if let error = error, case .accountAbnormal = error {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.yellow)
                        } else {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        }
                    case .testing:
                        ProgressView()
                    }
                }
            }
            .sheet(item: $sheetItem, content: { item in
                switch item {
                case let .gotVerification(verification):
                    NavigationView {
                        GeetestValidateView(
                            challenge: verification.challenge,
                            gt: verification.gt,
                            completion: { validate in
                                verifyValidate(challenge: verification.challenge, validate: validate)
                                sheetItem = nil
                            }
                        )
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("取消") {
                                    sheetItem = nil
                                }
                            }
                        }
                        .navigationTitle("account.test.verify.web_sheet.title")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .navigationViewStyle(.stack)
                }
            })
            if connectStatus == .fail, let error = error, case .accountAbnormal = error {
                Text("账号状态异常，需要输入验证码")
                Button("请点击此处输入验证码") {
                    popVerificationWebSheet()
                }
            } else {
                if connectStatus == .fail {
                    InfoPreviewer(title: "错误内容", content: error?.description ?? "")
                    InfoPreviewer(title: "DEBUG", content: error?.message ?? "")
                        .foregroundColor(.gray)
                }
            }

            if connectStatus == .success {
                if !cookie.contains("stoken"), server.region == .cn {
                    Label {
                        Text("本帐号无stoken，可能影响简洁模式下小组件使用。建议重新登录以获取stoken。")
                    } icon: {
                        Image(
                            systemName: "checkmark.circle.trianglebadge.exclamationmark"
                        )
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $is1034WebShown, content: {
            NavigationView {
                WebBroswerView(
                    url: "https://gi.pizzastudio.org/static/1034_error_soution"
                )
                .dismissableSheet(isSheetShow: $is1034WebShown)
                .navigationTitle("1034问题的解决方案")
                .navigationBarTitleDisplayMode(.inline)
            }
        })
        .onAppear {
            if connectStatus == .testing {
                MihoyoAPI.fetchInfos(
                    region: server.region,
                    serverID: server.id,
                    uid: uid,
                    cookie: cookie,
                    deviceFingerPrint: deviceFingerPrint
                ) { result in
                    switch result {
                    case .success:
                        connectStatus = .success
                    case let .failure(error):
                        connectStatus = .fail
                        self.error = error
                    }
                }
            }
        }
        .onChange(of: connectStatus) { newValue in
            if newValue == .testing {
                MihoyoAPI.fetchInfos(
                    region: server.region,
                    serverID: server.id,
                    uid: uid,
                    cookie: cookie,
                    deviceFingerPrint: deviceFingerPrint
                ) { result in
                    switch result {
                    case .success:
                        connectStatus = .success
                    case let .failure(error):
                        connectStatus = .fail
                        self.error = error
                    }
                }
            }
        }
        .onChange(of: error) { _ in
            if case .accountAbnormal = error {
                popVerificationWebSheet()
            }
        }
    }

    func popVerificationWebSheet() {
        Task(priority: .userInitiated) {
            do {
                let verification = try await MihoyoAPI.createVerification(
                    cookie: cookie,
                    deviceFingerPrint: deviceFingerPrint
                )
                sheetItem = .gotVerification(verification)
            } catch {
                verificationError = error
            }
        }
    }

    func verifyValidate(challenge: String, validate: String) {
        Task {
            do {
                _ = try await MihoyoAPI.verifyVerification(
                    challenge: challenge,
                    validate: validate,
                    cookie: cookie,
                    deviceFingerPrint: deviceFingerPrint
                )
                connectStatus = .testing
                viewModel.refreshData()
            } catch {
                verificationError = error
            }
        }
    }

    func isInstallation(urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        } else {
            return false
        }
    }

    // MARK: Private

    private enum SheetItem: Identifiable {
        case gotVerification(Verification)

        // MARK: Internal

        var id: Int {
            switch self {
            case let .gotVerification(verification):
                return verification.challenge.hashValue
            }
        }
    }

    @State
    private var verificationError: Error?

    @State
    private var error: FetchError?

    @State
    private var is1034WebShown: Bool = false

    @State
    private var sheetItem: SheetItem?
}

// MARK: - GeetestValidateView

struct GeetestValidateView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        // MARK: Lifecycle

        init(_ parent: GeetestValidateView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: GeetestValidateView

        // Receive message from website
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            if message.name == "callbackHandler" {
                if let messageBody = message.body as? String {
                    print("validate: \(messageBody)")
                    parent.finishWithValidate(messageBody)
                }
            }
        }
    }

    let challenge: String
    // swiftlint:disable:next identifier_name
    let gt: String

    let webView = WKWebView()
    @State
    private var isValidationObtained = false // 标识是否已获取到 validate.value 的内容

    @State
    var completion: (String) -> ()

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.removeAllScriptMessageHandlers()
        webView.configuration.userContentController.add(context.coordinator, name: "callbackHandler")
        webView.customUserAgent = """
        Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
        """
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let url = URL(string: "https://gi.pizzastudio.org/geetest/")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "challenge", value: challenge),
            URLQueryItem(name: "gt", value: gt),
        ]
        guard let finalURL = components?.url else {
            return
        }

        var request = URLRequest(url: finalURL)
        request.allHTTPHeaderFields = [
            "Referer": "https://webstatic.mihoyo.com",
        ]

        uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func finishWithValidate(_ validate: String) {
        completion(validate)
    }
}
