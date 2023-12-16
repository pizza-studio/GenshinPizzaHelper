//
//  GetGachaClipboardView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/4/2.
//

import AlertToast
import SFSafeSymbols
import SwiftUI

// MARK: - GetGachaClipboardView

@available(iOS 15.0, *)
struct GetGachaClipboardView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>
    @Environment(\.scenePhase)
    var scenePhase: ScenePhase

    @StateObject
    var gachaViewModel: GachaViewModel = .shared
    @StateObject
    var observer: GachaFetchProgressObserver = .shared

    @State
    var status: GetGachaStatus = .waitToStart

    @State
    fileprivate var isHelpSheetShow: Bool = false

    @State
    var urls: [String] = []

    @State
    fileprivate var alert: AlertType?
    fileprivate var isGetURLSucceedAlertShow: Binding<Bool> {
        .init {
            if case .getGachaURLSucceed = alert {
                return true
            } else {
                return false
            }
        } set: { newValue in
            if newValue == false {
                alert = nil
            }
        }
    }

    fileprivate var isUrlInPasteboardIsInvalidAlertShow: Binding<Bool> {
        .init {
            if case .urlInPasteboardIsInvalid(url: _) = alert {
                return true
            } else {
                return false
            }
        } set: { newValue in
            if newValue == false {
                alert = nil
            }
        }
    }

    fileprivate var isPasteboardNoDataAlertShow: Binding<Bool> {
        .init {
            if case .pasteboardNoData = alert {
                return true
            } else {
                return false
            }
        } set: { newValue in
            if newValue == false {
                alert = nil
            }
        }
    }

    @State
    var isCompleteGetGachaRecordAlertShow: Bool = false
    @State
    var isErrorGetGachaRecordAlertShow: Bool = false

    var body: some View {
        List {
            if urls.isEmpty {
                Section {
                    Button("app.gacha.get.url.clipboard") {
                        if let str = UIPasteboard.general.string {
                            if case .success =
                                parseURLToAuthkeyAndOtherParams(urlString: str) {
                                withAnimation {
                                    urls.append(str)
                                }
                                alert = .getGachaURLSucceed
                            } else {
                                alert = .urlInPasteboardIsInvalid(url: str)
                            }
                        } else {
                            alert = .pasteboardNoData
                        }
                    }
                }
            } else {
                Section {
                    Label {
                        Text("app.gacha.get.url.success")
                    } icon: {
                        Image(systemSymbol: .checkmarkCircle)
                            .foregroundColor(.green)
                    }

                } footer: {
                    HStack {
                        Spacer()
                        Button("app.gacha.get.url.retry") {
                            urls = []
                        }.font(.caption)
                    }
                }
            }

            if status != .running {
                Button(urls.isEmpty ? "app.gacha.get.waiting" : "app.gacha.get.start") {
                    observer.initialize()
                    status = .running
                    let parseResults = urls.compactMap { urlString in
                        try? parseURLToAuthkeyAndOtherParams(
                            urlString: urlString
                        )
                        .get()
                    }
                    if parseResults.isEmpty {
                        withAnimation {
                            status =
                                .failure(.genAuthKeyError(message: "URL Error"))
                        }
                    } else {
                        let (authkey, server) = parseResults.last!
                        gachaViewModel.getGachaAndSaveFor(
                            server: server,
                            authkey: authkey,
                            observer: observer
                        ) { result in
                            switch result {
                            case .success:
                                withAnimation {
                                    status = .succeed
                                }
                            case let .failure(error):
                                withAnimation {
                                    status = .failure(error)
                                }
                            }
                        }
                    }
                }
                .disabled(urls.isEmpty)
            } else {
                GettingGachaBar()
            }
            GetGachaResultView(status: $status)
        }
        .onChange(of: status, perform: { newValue in
            switch newValue {
            case .succeed:
                isCompleteGetGachaRecordAlertShow.toggle()
            case .failure:
                isErrorGetGachaRecordAlertShow.toggle()
            default:
                break
            }
        })
        .toast(isPresenting: $isCompleteGetGachaRecordAlertShow, alert: {
            .init(
                displayMode: .alert,
                type: .complete(.green),
                title: "app.gacha.get.success".localized,
                subTitle: String(
                    format: "gacha.messages.newEntriesSaved:%lld".localized,
                    observer.newItemCount
                )
            )
        })
        .toast(isPresenting: $isErrorGetGachaRecordAlertShow, alert: {
            guard case let .failure(error) = status
            else { return .init(displayMode: .alert, type: .loading) }
            let errorTitle = String(format: "app.gacha.get.error:%@".localized, error.localizedDescription)
            return .init(
                displayMode: .alert,
                type: .error(.red),
                title: errorTitle
            )
        })
        .sheet(isPresented: $isHelpSheetShow, content: {
            HelpSheet(isPresented: $isHelpSheetShow)
        })
        .navigationBarBackButtonHidden(status == .running)
        .alert(
            "app.gacha.get.link.success",
            isPresented: isGetURLSucceedAlertShow,
            presenting: alert,
            actions: { _ in },
            message: { _ in
                Text("app.gacha.get.link.continue")
            }
        )
        .alert(
            "app.gacha.get.url.invalidUrl",
            isPresented: isUrlInPasteboardIsInvalidAlertShow,
            presenting: alert,
            actions: { _ in },
            message: { alert in
                switch alert {
                case let .urlInPasteboardIsInvalid(url: url):
                    let errorContent = String(format: "app.gacha.get.url.error:%@".localized, url)
                    Text(errorContent)
                default:
                    EmptyView()
                }
            }
        )
        .alert("app.gacha.get.url.clipboardNil", isPresented: isPasteboardNoDataAlertShow, actions: {})
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isHelpSheetShow.toggle()
                } label: {
                    Image(systemSymbol: .questionmarkCircle)
                }
            }
        }
        .navigationTitle("app.gacha.get.title")
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(observer)
    }
}

// MARK: - AlertType

private enum AlertType {
    case urlInPasteboardIsInvalid(url: String)
    case getGachaURLSucceed
    case pasteboardNoData
}

// MARK: Identifiable

extension AlertType: Identifiable {
    var id: String {
        switch self {
        case let .urlInPasteboardIsInvalid(url: url):
            return "urlInPasteboardIsInvalid\(url)"
        case .getGachaURLSucceed:
            return "getGachaURLSucceed"
        case .pasteboardNoData:
            return "pasteboardNoData"
        }
    }
}

// MARK: - HelpSheet

private struct HelpSheet: View {
    @Binding
    var isPresented: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Link(
                        "app.gacha.get.url.paimonMoe",
                        destination: URL(
                            string: "https://paimon.moe/wish/import"
                        )!
                    )
                } header: {
                    Text("app.gacha.get.url.other")
                } footer: {
                    Text("app.gacha.get.url.other.detail")
                }
            }
            .navigationTitle("sys.help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
                        isPresented.toggle()
                    }
                }
            }
        }
    }
}
