//
//  MIMTGetGachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/4/1.
//

#if canImport(GachaMIMTServer)

import GachaMIMTServer
import HBMihoyoAPI
import NetworkExtension
import SwiftUI

private var ALREADY_INSTALL_CA_STORAGE_KEY: Bool {
    get {
        UserDefaults.standard.bool(forKey: "alreadyInstallCA")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "alreadyInstallCA")
    }
}

private var IS_GACHA_HELPSHEET_SHOWN: Bool {
    get {
        UserDefaults.standard.bool(forKey: "isGachaHelpsheetShown")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "isGachaHelpsheetShown")
    }
}

// MARK: - MIMTGetGachaView

struct MIMTGetGachaView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>
    @Environment(\.scenePhase)
    var scenePhase: ScenePhase
    @ObservedObject
    private var manager: VPNManager = .shared
    @StateObject
    var gachaViewModel: GachaViewModel = .shared
    @StateObject
    var observer: GachaFetchProgressObserver = .shared

    @State
    var status: GetGachaStatus = .waitToStart

    @State
    fileprivate var sheetType: SheetType?

    @State
    var urls: [String] = []

    @State
    fileprivate var alert: AlertType?

    var body: some View {
        List {
            if urls.isEmpty {
                Section {
                    Text(manager.status.description)
                        .foregroundColor(
                            manager
                                .status == .connected ? .green : .red
                        )
                    switch manager.status {
                    case .connected:
                        Button("停止抓包") {
                            manager.stop()
                        }
                    case .connecting:
                        ProgressView()
                    case .notConnected:
                        Button("开始抓包") {
                            manager.start()
                        }
                    }
                } header: {
                    Text("通过抓包获取获取祈愿链接")
                }
                Section {
                    Button("从粘贴板中获取祈愿URL") {
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
                        Text("成功获取到祈愿链接")
                    } icon: {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                    }

                } footer: {
                    HStack {
                        Spacer()
                        Button("重新祈愿链接") {
                            urls = []
                        }.font(.caption)
                    }
                }
            }

            if status != .running {
                Button(urls.isEmpty ? "等待祈愿链接..." : "开始获取祈愿记录") {
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
        .sheet(item: $sheetType, onDismiss: {
            if !IS_GACHA_HELPSHEET_SHOWN {
                sheetType = .helpSheet
            }
        }, content: { type in
            switch type {
            case .caInstall:
                CASheet(
                    sheetType: $sheetType,
                    parentPresentationMode: presentationMode
                )
            case .helpSheet:
                HelpSheet(sheetType: $sheetType)
            }
        })
        .onChange(of: scenePhase) { newValue in
            if newValue == .active {
                if urls.isEmpty {
                    if let urls = popURLsFromStorage() {
                        withAnimation {
                            self.urls = urls
                            manager.stop()
                        }
                    } else {
                        print("no url in storage")
                    }
                }
                manager.refreshVPNStatus()
            }
        }
        .navigationBarBackButtonHidden(status == .running)
        .environmentObject(observer)
        .alert(item: $alert) { alert in
            switch alert {
            case .getGachaURLSucceed:
                return Alert(
                    title: Text("成功获取到祈愿记录链接"),
                    message: Text("请点击”开始获取祈愿记录“以继续")
                )
            case let .urlInPasteboardIsInvalid(url: url):
                return Alert(
                    title: Text("从粘贴板上获取到的链接有误"),
                    message: Text("预期应获取到祈愿链接，但获取到了错误的内容：\n\(url)")
                )
            case .pasteboardNoData:
                return Alert(title: Text("未能从粘贴板获取到内容"))
            }
        }
        .onAppear {
            if !ALREADY_INSTALL_CA_STORAGE_KEY {
                sheetType = .caInstall
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    sheetType = .helpSheet
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .navigationTitle("获取祈愿记录")
        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            DispatchQueue.global(qos: .background).async {
//                checkURLStorageAndGet()
//            }
//        }
    }

//    func checkURLStorageAndGet() {
//        if urls.isEmpty, let urls = popURLsFromStorage() {
//            withAnimation {
//                self.urls = urls
//                manager.stop()
//            }
//        } else {
//            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 3.0) {
//                checkURLStorageAndGet()
//            }
//        }
//    }
}

// MARK: - SheetType

private enum SheetType: Int, Identifiable {
    case caInstall
    case helpSheet

    // MARK: Internal

    var id: Int { rawValue }
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

// MARK: - CASheetItems

private struct CASheetItems: View {
    var body: some View {
        Section {
            HStack {
                Spacer()
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.yellow)
                Spacer()
            }
            Text("在进行抓包获取祈愿链接前，您需要根据以下3个步骤安装CA证书。")
            Text("如您在抓包过程中无法连接互联网，请检查本页面所有3个步骤是否完成。")
        }
        Section {
            Text("您也可以选择根据跟随以下视频进行安装CA证书。")
            Link(destination: URL(
                string: "https://www.bilibili.com/video/BV1Lg411S7wa"
            )!) {
                Label {
                    Text("打开Bilibili观看")
                } icon: {
                    Image("bilibili")
                        .resizable()
                        .foregroundColor(.blue)
                        .scaledToFit()
                }
            }
            Link(
                destination: URL(
                    string: "https://www.youtube.com/watch?v=k9G2N8XYFm4"
                )!
            ) {
                Label {
                    Text("打开YouTube观看")
                } icon: {
                    Image("youtube")
                        .resizable()
                        .foregroundColor(.blue)
                        .scaledToFit()
                }
            }
        }
        Section {
            Label("下载CA证书", systemImage: "1.circle")
            Text("点击以下链接下载CA证书。")
            Link(
                destination: URL(
                    string: "http://ophelper.top/api/app/PizzaCA.pem"
                )!
            ) {
                Label("下载CA证书", systemImage: "lock.doc")
            }
            Label("安装CA证书", systemImage: "2.circle")
            Text(
                "前往「设置」App -> 「通用」 -> 「VPN与设备管理」 -> （已下载的描述文件）「Pizza Helper CA」 -> 「安装」"
            )
            Label("信任CA证书", systemImage: "3.circle")
            Text(
                "前往「设置」App -> 「通用」 -> 「关于本机」 -> （最下方）「信任证书设置」 -> 打开「Pizza Helper CA」开关"
            )
        } header: {
            Text("如何安装CA证书？")
        }
    }
}

// MARK: - HelpSheet

private struct HelpSheet<V>: View {
    @Binding
    var sheetType: V?
    @State
    var isCASheetShow: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("CA证书相关") {
                        List {
                            CASheetItems()
                        }
                        .navigationTitle("CA证书安装教程")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                } header: {
                    Text("关于CA证书")
                } footer: {
                    Text("请务必确保CA证书下载、安装、信任。")
                }
                Section {
                    Label(
                        "您的手机需要安装《原神》并处于能够正常游玩游戏的网络环境下。",
                        systemImage: "gamecontroller"
                    )
                    Label("点击「开始抓包」按钮。", systemImage: "1.circle")
                    Label(
                        "返回主屏幕，打开《原神》并打开祈愿界面，点击「历史记录」按钮。如成功获取到链接，本软件会向您推送一条通知。",
                        systemImage: "2.circle"
                    )
                    Label(
                        "返回本软件，点击「开始获取祈愿记录」按钮，等待获取完成。",
                        systemImage: "3.circle"
                    )
                } header: {
                    Text("如何获取祈愿链接？")
                }
                Section {
                    Link(destination: URL(
                        string: "https://www.bilibili.com/video/BV1Lg411S7wa"
                    )!) {
                        Label {
                            Text("打开Bilibili观看")
                        } icon: {
                            Image("bilibili")
                                .resizable()
                                .foregroundColor(.blue)
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://www.youtube.com/watch?v=k9G2N8XYFm4"
                        )!
                    ) {
                        Label {
                            Text("打开YouTube观看")
                        } icon: {
                            Image("youtube")
                                .resizable()
                                .foregroundColor(.blue)
                                .scaledToFit()
                        }
                    }
                } header: {
                    Text("视频教程")
                } footer: {
                    Text("您也可以选择根据跟随我们的视频教程获取祈愿记录。")
                }
                Section {
                    NavigationLink("PC端或安卓手机通过本软件获取祈愿记录的方法") {
                        Text("待补充")
                    }
                    Link(
                        "由paimon.moe提供的方法",
                        destination: URL(
                            string: "https://paimon.moe/wish/import"
                        )!
                    )
                } header: {
                    Text("其他获取祈愿链接的方法")
                } footer: {
                    Text("您可以将其他软件获取的祈愿链接粘贴至本软件以获取祈愿记录。但本软件不对外部程序可靠性负责。")
                }
            }
            .navigationTitle("帮助")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        sheetType = nil
                        IS_GACHA_HELPSHEET_SHOWN = true
                    }
                }
            }
        }
    }
}

// MARK: - CASheet

private struct CASheet<V>: View {
    @Binding
    var sheetType: V?
    @Binding
    var parentPresentationMode: PresentationMode

    @State
    var isAlertShow: Bool = false

    var body: some View {
        NavigationView {
            List {
                CASheetItems()
            }
            .navigationTitle("安装CA证书")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        if !ALREADY_INSTALL_CA_STORAGE_KEY {
                            isAlertShow = true
                        } else {
                            sheetType = nil
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        sheetType = nil
                        if !ALREADY_INSTALL_CA_STORAGE_KEY {
                            parentPresentationMode.dismiss()
                        }
                    }
                }
            }
        }
        .alert(isPresented: $isAlertShow) {
            Alert(
                title: Text("确认已经下载、安装并信任CA证书？"),
                message: Text("未正确下载、安装或信任CA证书可能会导致URL抓取功能失效等问题"),
                primaryButton: .destructive(Text("我已经下载、安装并信任了CA证书"), action: {
                    ALREADY_INSTALL_CA_STORAGE_KEY = true
                    sheetType = nil
                }),
                secondaryButton: .cancel(Text("返回"))
            )
        }
    }
}

// MARK: - VPNManager

private class VPNManager: ObservableObject {
    // MARK: Lifecycle

    private init() {
        makeManagerIfNoOther()
        listenVPNStatus()
    }

    // MARK: Internal

    enum VPNStatus {
        case connecting
        case connected
        case notConnected
    }

    static let shared = VPNManager()

    var manager: NETunnelProviderManager = .init()

    @Published
    var status: VPNStatus = .notConnected

    func makeManagerIfNoOther() {
        NETunnelProviderManager
            .loadAllFromPreferences { [self] managers, error in
                if let error = error {
                    print(error)
                }
                if let managers = managers {
                    if !managers.isEmpty {
                        manager = managers[0]
                    }
                }

                manager.loadFromPreferences { error in
                    if let error = error { print(error) }
                    self.manager.protocolConfiguration = self
                        .managerProtocolConfiguration()
                    self.manager.localizedDescription = "PizzaVPN"
                    self.manager.isEnabled = true

                    self.manager.saveToPreferences { error in
                        if let error = error {
                            print(error)
                        }
                    }
                }
            }
    }

    func managerProtocolConfiguration() -> NETunnelProviderProtocol {
        let proto = NETunnelProviderProtocol()
        // Replace with an actual VPN server address
        proto.serverAddress = "127.0.0.1:3000"
        return proto
    }

    func start() {
        withAnimation {
            self.manager.loadFromPreferences { error in
                if let error = error { print(error) }
                do {
                    try self.manager.connection.startVPNTunnel()
                } catch {
                    print(error)
                }
            }
            refreshVPNStatus()
        }
    }

    func stop() {
        withAnimation {
            manager.connection.stopVPNTunnel()
            refreshVPNStatus()
        }
    }

    func refreshVPNStatus() {
        withAnimation {
            switch manager.connection.status {
            case .connected:
                self.status = .connected
            case .connecting:
                self.status = .connecting
            default:
                self.status = .notConnected
            }
        }
    }

    func listenVPNStatus() {
        withAnimation {
            switch manager.connection.status {
            case .connected:
                self.status = .connected
            case .connecting:
                self.status = .connecting
            default:
                self.status = .notConnected
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.listenVPNStatus()
        }
    }
}

// MARK: - VPNManager.VPNStatus + CustomStringConvertible

extension VPNManager.VPNStatus: CustomStringConvertible {
    var description: String {
        switch self {
        case .connected:
            return "正在抓包...请前往打开「原神」前往祈愿记录页面"
        case .connecting:
            return "正在开启VPN"
        case .notConnected:
            return "等待开始..."
        }
    }
}

func popURLsFromStorage() -> [String]? {
    let decoder = JSONDecoder()

    let APP_GROUP_IDENTIFIER = "group.GenshinPizzaHelper"
    let MIMT_URL_STORAGE_KEY = "mimtURLArray"
    let storage = UserDefaults(suiteName: APP_GROUP_IDENTIFIER)!
    if let arrayJsonString = storage.string(forKey: MIMT_URL_STORAGE_KEY) {
        clean()
        return try? decoder.decode(
            [String].self,
            from: arrayJsonString.data(using: .utf8)!
        )
    } else {
        clean()
        return nil
    }
    func clean() {
        let encoder = JSONEncoder()
        storage.set(
            String(data: try! encoder.encode([String].init()), encoding: .utf8),
            forKey: MIMT_URL_STORAGE_KEY
        )
    }
}

private func parseURLToAuthkeyAndOtherParams(urlString: String)
    -> Result<
        (authKey: GenAuthKeyResult.GenAuthKeyData, server: Server),
        GetGachaError
    > {
    guard let url = URL(string: urlString)
    else {
        return .failure(.genAuthKeyError(message: "URL Error: \(urlString)"))
    }
    let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?
        .queryItems
    guard let items = queryItems
    else {
        return .failure(.genAuthKeyError(message: "URL Error: \(urlString)"))
    }
    guard let authkey = items.first(where: { $0.name == "authkey" })?.value
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no authkey): \(urlString)")
        )
    }
    guard let signTypeString = items.first(where: { $0.name == "sign_type" })?
        .value
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no sign_type): \(urlString)")
        )
    }
    guard let signType = Int(signTypeString)
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no sign_type): \(urlString)")
        )
    }
    guard let authkeyVerString = items
        .first(where: { $0.name == "authkey_ver" })?.value
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no sign_type): \(urlString)")
        )
    }
    guard let authkeyVer = Int(authkeyVerString)
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no sign_type): \(urlString)")
        )
    }
    guard let serverId = items.first(where: { $0.name == "region" })?.value
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no sign_type): \(urlString)")
        )
    }

    return .success(
        (
            GenAuthKeyResult
                .GenAuthKeyData(
                    authkeyVer: authkeyVer,
                    signType: signType,
                    authkey: authkey
                ),
            Server.id(serverId)
        )
    )
}

#endif
