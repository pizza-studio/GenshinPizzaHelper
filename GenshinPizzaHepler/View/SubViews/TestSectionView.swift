//
//  TestView.swift
//  原神披萨小助手
//
//  Created by 戴藏龙 on 2022/8/8.
//  测试连接部分的View

import HBMihoyoAPI
import HoYoKit
import SFSafeSymbols
import SwiftUI
import WebKit

//// MARK: - TestSectionView
//
// struct TestSectionView: View {
//    // MARK: Internal
//
//    @EnvironmentObject
//    var viewModel: ViewModel
//
//    @Binding
//    var connectStatus: ConnectStatus
//
//    @Binding
//    var uid: String
//    @Binding
//    var cookie: String
//    @Binding
//    var server: Server
//    @Binding
//    var deviceFingerPrint: String
//    let deviceId: UUID
//
//    var body: some View {
//        Section {
//            Button(action: {
//                connectStatus = .testing
//            }) {
//                HStack {
//                    Text("settings.account.testConnection")
//                    Spacer()
//                    switch connectStatus {
//                    case .unknown:
//                        Text("")
//                    case .success:
//                        Image(systemSymbol: .checkmark)
//                            .foregroundColor(.green)
//                    case .fail:
//                        if let error = error, case .accountAbnormal = error {
//                            Image(systemSymbol: .questionmarkCircle)
//                                .foregroundColor(.yellow)
//                        } else {
//                            Image(systemSymbol: .xmark)
//                                .foregroundColor(.red)
//                        }
//                    case .testing:
//                        ProgressView()
//                    }
//                }
//            }
//            .sheet(item: $sheetItem, content: { item in
//                switch item {
//                case let .gotVerification(verification):
//                    NavigationStack {
//                        GeetestValidateView(
//                            challenge: verification.challenge,
//                            gt: verification.gt,
//                            completion: { validate in
//                                verifyValidate(challenge: verification.challenge, validate: validate)
//                                sheetItem = nil
//                            }
//                        )
//                        .toolbar {
//                            ToolbarItem(placement: .navigationBarLeading) {
//                                Button("sys.cancel") {
//                                    sheetItem = nil
//                                }
//                            }
//                        }
//                        .navigationTitle("account.test.verify.web_sheet.title")
//                        .navigationBarTitleDisplayMode(.inline)
//                    }
//                }
//            })
//            if connectStatus == .fail, let error = error, case .accountAbnormal = error {
//                Text("testSectionView.accountStatusAbnormal.promptForVerification")
//                Button("testSectionView.clickHereForVerification") {
//                    popVerificationWebSheet()
//                }
//            } else {
//                if connectStatus == .fail {
//                    InfoPreviewer(title: "settings.account.errorMessage", content: error?.description ?? "")
//                    InfoPreviewer(title: "DEBUG", content: error?.message ?? "")
//                        .foregroundColor(.gray)
//                }
//            }
//
//            if connectStatus == .success {
//                if !cookie.contains("stoken"), server.region == .mainlandChina {
//                    Label {
//                        Text("本账号无stoken，可能影响简洁模式下小组件使用。建议重新登录以获取stoken。")
//                    } icon: {
//                        Image(
//                            systemName: "checkmark.circle.trianglebadge.exclamationmark"
//                        )
//                        .foregroundColor(.red)
//                    }
//                }
//            }
//        }
//        .sheet(isPresented: $is1034WebShown, content: {
//            NavigationStack {
//                WebBroswerView(
//                    url: "https://gi.pizzastudio.org/static/1034_error_soution"
//                )
//                .dismissableSheet(isSheetShow: $is1034WebShown)
//                .navigationTitle("1034问题的解决方案")
//                .navigationBarTitleDisplayMode(.inline)
//            }
//        })
//        .onAppear {
//            let uuid: UUID
//            if let id = UIDevice.current.identifierForVendor {
//                uuid = id
//                print("get device_id success, using \(uuid)")
//            } else {
//                uuid = UUID()
//                print("get device_id fail, using \(uuid)")
//            }
//            if connectStatus == .testing {
//                MihoyoAPI.fetchInfos(
//                    region: server.region,
//                    serverID: server.id,
//                    uid: uid,
//                    cookie: cookie,
//                    uuid: uuid,
//                    deviceFingerPrint: deviceFingerPrint
//                ) { result in
//                    switch result {
//                    case .success:
//                        connectStatus = .success
//                    case let .failure(error):
//                        connectStatus = .fail
//                        self.error = error
//                    }
//                }
//            }
//        }
//        .onChange(of: connectStatus) { newValue in
//            let uuid: UUID
//            if let id = UIDevice.current.identifierForVendor {
//                uuid = id
//                print("get device_id success, using \(uuid)")
//            } else {
//                uuid = UUID()
//                print("get device_id fail, using \(uuid)")
//            }
//            if newValue == .testing {
//                MihoyoAPI.fetchInfos(
//                    region: server.region,
//                    serverID: server.id,
//                    uid: uid,
//                    cookie: cookie,
//                    uuid: uuid,
//                    deviceFingerPrint: deviceFingerPrint
//                ) { result in
//                    switch result {
//                    case .success:
//                        connectStatus = .success
//                    case let .failure(error):
//                        connectStatus = .fail
//                        self.error = error
//                    }
//                }
//            }
//        }
//        .onChange(of: error) { _ in
//            if case .accountAbnormal = error {
//                popVerificationWebSheet()
//            }
//        }
//    }
//
//    func popVerificationWebSheet() {
//        Task(priority: .userInitiated) {
//            do {
//                let verification = try await MiHoYoAPI.createVerification(
//                    cookie: cookie,
//                    deviceFingerPrint: deviceFingerPrint, deviceId: deviceId
//                )
//                sheetItem = .gotVerification(verification)
//            } catch {
//                verificationError = error
//            }
//        }
//    }
//
//    func verifyValidate(challenge: String, validate: String) {
//        Task {
//            do {
//                _ = try await MiHoYoAPI.verifyVerification(
//                    challenge: challenge,
//                    validate: validate,
//                    cookie: cookie,
//                    deviceFingerPrint: deviceFingerPrint, deviceId: deviceId
//                )
//                connectStatus = .testing
//                viewModel.refreshData()
//            } catch {
//                verificationError = error
//            }
//        }
//    }
//
//    func isInstallation(urlString: String) -> Bool {
//        if let url = URL(string: urlString) {
//            return UIApplication.shared.canOpenURL(url)
//        } else {
//            return false
//        }
//    }
//
//    // MARK: Private
//
//    private enum SheetItem: Identifiable {
//        case gotVerification(Verification)
//
//        // MARK: Internal
//
//        var id: Int {
//            switch self {
//            case let .gotVerification(verification):
//                return verification.challenge.hashValue
//            }
//        }
//    }
//
//    @State
//    private var verificationError: Error?
//
//    @State
//    private var error: FetchError?
//
//    @State
//    private var is1034WebShown: Bool = false
//
//    @State
//    private var sheetItem: SheetItem?
// }
