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

// MARK: - MoreView

struct MoreView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                NavigationLink(destination: UpdateHistoryInfoView()) {
                    Text("检查更新")
                }
                #if DEBUG
                Button("清空已检查的版本号") {
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
                Text(
                    "settings.more.timeZone.descriptionWithCurrent:\((Server(rawValue: defaultServer) ?? .asia).timeZone().identifier)"
                )
            }

            Section {
                Toggle("settings.more.useEnkaJSONFromGitHosts", isOn: $useEnkaJSONFromGitHosts)
            }

            Section {
                Link(
                    "gacha.term.scriptForFetchingCookies",
                    destination: URL(
                        string: "https://www.icloud.com/shortcuts/fe68f22c624949c9ad8959993239e19c"
                    )!
                )
            }
            // FIXME: Proxy not implemented
            Section {
                NavigationLink(destination: ReverseProxySettingsView()) {
                    Text("settings.reverseProxy.navTitle")
                }
            }

            Section {
                NavigationLink(destination: IconSettingsView()) {
                    Text("settings.icon.xinzoruo.toggle")
                }
            }

            Section {
                Link(destination: URL(string: "https://apps.apple.com/app/id6448894222")!) {
                    HStack {
                        Image("icon.hsrhelper")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                        VStack(alignment: .leading) {
                            Text("settings.siblingApps.PizzaHelper4HSR.title")
                                .foregroundColor(.primary)
                            Text("settings.siblingApps.PizzaHelper4HSR.description")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                        Image(systemSymbol: .chevronForward)
                    }
                }
                Link(destination: URL(string: "https://apps.apple.com/cn/app/id6450712191")!) {
                    HStack {
                        Image("icon.herta_terminal")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                        VStack(alignment: .leading) {
                            Text("settings.siblingApps.HertaTerminal.title")
                                .foregroundColor(.primary)
                            Text("settings.siblingApps.HertaTerminal.description")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                        Image(systemSymbol: .chevronForward)
                    }
                }
            } header: {
                Text("settings.siblingApps")
            }

            Section {
                NavigationLink(
                    destination: WebBroswerView(
                        url: "https://gi.pizzastudio.org/static/policy.html"
                    )
                    .navigationTitle("settings.misc.EULA")
                ) {
                    Text("settings.misc.disclaimer")
                }
                NavigationLink(destination: AboutView()) {
                    Text("settings.misc.aboutThisApp")
                }
            }

            Section {
                Button(
                    "settings.more.cleanCacheFilesOfMBs:\(String(format: "%.2f", viewModel.fileSize))"
                ) {
                    viewModel.clearImageCache()
                }
            }
        }
        .navigationBarTitle("settings.more", displayMode: .inline)
    }

    // MARK: Private

    @ObservedObject
    private var viewModel: MoreViewCacheViewModel = .init()

    @Default(.defaultServer)
    private var defaultServer: String

    @Default(.useEnkaJSONFromGitHosts)
    private var useEnkaJSONFromGitHosts: Bool
}

// MARK: - MoreViewCacheViewModel

class MoreViewCacheViewModel: ObservableObject {
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
