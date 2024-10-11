//
//  HelpSheetView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/8.
//  更多页面

import Defaults
import HBMihoyoAPI
import HoYoKit
import SFSafeSymbols
import SwiftUI

// MARK: - OtherSettingsView

struct OtherSettingsView: View {
    // MARK: Public

    @ViewBuilder
    public static var linksForManagingHoYoLabAccounts: some View {
        Link(destination: URL(string: "https://user.mihoyo.com/")!) {
            Text("sys.server.cn") + Text(verbatim: " - ") + Text("app.miyoushe")
        }
        Link(destination: URL(string: "https://account.hoyoverse.com/")!) {
            Text("sys.server.os") + Text(verbatim: " - HoYoLAB")
        }
    }

    // MARK: Internal

    var body: some View {
        List {
            Section {
                NavigationLink(destination: UpdateHistoryInfoView()) {
                    Text("settings.update.title")
                }
                #if DEBUG
                Button("settings.update.cleanChecked") {
                    Defaults.reset(.checkedUpdateVersions)
                    Defaults.reset(.checkedNewestVersion)
                    UserDefaults.opSuite.synchronize()
                }
                #endif
            }
            Section {
                Picker("settings.more.timeZone.title", selection: $defaultServer) {
                    ForEach(Server.allCases) { server in
                        Text(server.localized).tag(server.rawValue)
                    }
                }
            } footer: {
                let identifier = (Server(rawValue: defaultServer) ?? .asia).timeZone().identifier
                Text("settings.more.timeZone.descriptionWithCurrent:\(identifier)")
            }

            Section {
                Menu {
                    Self.linksForManagingHoYoLabAccounts
                } label: {
                    Text("sys.manage_hoyolab_account")
                }
            } footer: {
                Text("sys.manage_hoyolab_account.footer").textCase(.none)
            }

            Section {
                let urlStr = "https://www.icloud.com/shortcuts/fe68f22c624949c9ad8959993239e19c"
                Link("gacha.term.scriptForFetchingCookies", destination: URL(string: urlStr)!)
            }
            // FIXME: Proxy not implemented
            Section {
                NavigationLink(destination: ReverseProxySettingsView()) {
                    Text("settings.reverseProxy.navTitle")
                }
            }

            if isPhoneOrPad {
                Section {
                    NavigationLink(destination: IconSettingsView()) {
                        Text("settings.icon.xinzoruo.toggle")
                    }
                }
            }

            watchConnectivityPushView()

            pizzaStudioAppMetaSection()

            Section {
                NavigationLink("settings.misc.disclaimer") {
                    WebBrowserView(url: "https://gi.pizzastudio.org/static/policy.html")
                        .navigationTitle("settings.misc.EULA")
                }
                NavigationLink(destination: AboutView()) {
                    Text("settings.misc.aboutThisApp")
                }
            }

            Section {
                Button {
                    viewModel.clearImageCache()
                } label: {
                    buttonLabelForCleaningCache
                }
            }
        }
        .navigationBarTitle("settings.more", displayMode: .inline)
    }

    // MARK: Private

    private let isPhoneOrPad: Bool = [.iPhoneOS, .iPadOS].contains(OS.type)

    @ObservedObject
    private var viewModel: OtherSettingsViewCacheViewModel = .init()

    @Default(.defaultServer)
    private var defaultServer: String

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.priority, ascending: true)],
        animation: .default
    )
    private var accounts: FetchedResults<Account>

    private var buttonLabelForCleaningCache: Text {
        Text("settings.more.cleanCacheFilesOfMBs:\(String(format: "%.2f", viewModel.fileSize))")
    }

    @ViewBuilder
    private func pizzaStudioAppMetaSection() -> some View {
        Section {
            PizzaAppMetaSet(
                imageName: "icon.hsrhelper",
                nameKey: "settings.siblingApps.PizzaHelper4HSR.title",
                introKey: "settings.siblingApps.PizzaHelper4HSR.description",
                urlStr: "https://apps.apple.com/cn/app/id6448894222"
            )
            PizzaAppMetaSet(
                imageName: "icon.herta_terminal",
                nameKey: "settings.siblingApps.HertaTerminal.title",
                introKey: "settings.siblingApps.HertaTerminal.description",
                urlStr: "https://apps.apple.com/cn/app/id6450712191"
            )
        } header: {
            Text("settings.siblingApps")
        }
    }

    @ViewBuilder
    private func watchConnectivityPushView() -> some View {
        if WatchConnectivityManager.isSupported {
            Section {
                Button("sys.account.force_push") {
                    var accountInfo = String(localized: "sys.account.force_push.received")
                    for account in accounts {
                        accountInfo +=
                            "\(String(describing: account.name!)) (\(String(describing: account.uid!)))\n"
                    }
                    for account in accounts {
                        WatchConnectivityManager.shared.sendAccounts(account, accountInfo)
                    }
                }
            } footer: {
                Text("sys.account.force_push.footer")
                    .textCase(.none)
            }
        }
    }
}

// MARK: - OtherSettingsViewCacheViewModel

class OtherSettingsViewCacheViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        do {
            let fileUrls = try FileManager.default
                .contentsOfDirectory(atPath: imageFolderURL.path)
            self.fileSize = 0.0
            for fileUrl in fileUrls {
                let attributes = try FileManager.default
                    .attributesOfItem(
                        atPath: imageFolderURL
                            .appendingPathComponent(fileUrl).path
                    )
                fileSize += attributes[FileAttributeKey.size] as! Double
            }
            self.fileSize = fileSize / 1024.0 / 1024.0
        } catch {
            print("error get images size: \(error)")
            self.fileSize = 0.0
        }
    }

    // MARK: Internal

    let imageFolderURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!.appendingPathComponent("Images")
    @Published
    var fileSize: Double

    func clearImageCache() {
        do {
            let fileUrls = try FileManager.default
                .contentsOfDirectory(atPath: imageFolderURL.path)
            for fileUrl in fileUrls {
                try FileManager.default
                    .removeItem(
                        at: imageFolderURL
                            .appendingPathComponent(fileUrl)
                    )
            }
            fileSize = 0.0
            print("Image Cache Cleared!")
        } catch {
            print("error: Image Cache Clear:\(error)")
        }
    }
}

// MARK: - OtherSettingsView.PizzaAppMetaSet

extension OtherSettingsView {
    private struct PizzaAppMetaSet: Sendable, Identifiable, View {
        // MARK: Lifecycle

        public init(imageName: String, nameKey: String, introKey: String, urlStr: String) {
            self.imageName = imageName
            self.name = String(localized: .init(stringLiteral: nameKey))
            self.introduction = String(localized: .init(stringLiteral: introKey))
            self.destination = URL(string: urlStr)!
        }

        // MARK: Public

        public let name: String
        public let introduction: String
        public let destination: URL

        public var body: some View {
            Link(destination: destination) {
                HStack {
                    Image(imageName).resizable().frame(width: 50, height: 50).cornerRadius(10)
                    VStack(alignment: .leading) {
                        Text(verbatim: name).foregroundColor(.primary)
                        Text(verbatim: introduction).font(.footnote).foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemSymbol: .chevronForward)
                }
            }
        }

        // MARK: Internal

        let imageName: String

        var id: String { name }
    }
}
