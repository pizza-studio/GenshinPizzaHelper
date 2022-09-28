//
//  HelpSheetView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/8.
//  更多页面

import SwiftUI

struct MoreView: View {
    @EnvironmentObject var viewModel: ViewModel
    let localeID = Locale.current.identifier
    @State private var newestVersionInfos: NewestVersion? = nil
    @State var isJustUpdated: Bool = false
    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let buildVersion = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)!

    @StateObject var storeManager: StoreManager

    var body: some View {
        List {
            Section {
                NavigationLink(destination: newestVersionInfoView()) {
                    Text("检查更新")
                }
                #if DEBUG
                Button("清空已检查的版本号") {
                    UserDefaults.standard.set([], forKey: "checkedUpdateVersions")
                    UserDefaults.standard.synchronize()
                }
                #endif
            }
            Section {
                Link("获取Cookie的脚本", destination: URL(string: "https://www.icloud.com/shortcuts/fe68f22c624949c9ad8959993239e19c")!)
                NavigationLink(destination: BackgroundsPreviewView()) {
                    Text("背景名片预览")
                }
            }
            // FIXME: Proxy not implenmented
//            Section {
//                NavigationLink(destination: ProxySettingsView()) {
//                    Text("代理设置")
//                }
//            }
            Section {
                NavigationLink(destination: WebBroswerView(url: "http://ophelper.top/static/policy.html").navigationTitle("用户协议")) {
                    Text("用户协议与免责声明")
                }
                NavigationLink(destination: AboutView()) {
                    Text("关于小助手")
                }
            }
        }
        .navigationBarTitle("更多", displayMode: .inline)
    }

    @ViewBuilder
    func newestVersionInfoView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(newestVersionInfos?.shortVersion ?? "Error").font(.largeTitle) +
                Text(" (\(newestVersionInfos?.buildVersion ?? -1))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Image("AppIconHD")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
            }
            Divider()
                .padding(.vertical)
            Text("更新内容：")
                .font(.subheadline)
            if newestVersionInfos != nil {
                ForEach(getLocalizedUpdateInfos(meta: newestVersionInfos!), id:\.self) { item in
                    Text("- \(item)")
                }
            } else {
                Text("Error")
                    .onAppear(perform: checkNewestVersion)
            }
            if !isJustUpdated {
                switch AppConfig.appConfiguration {
                case .TestFlight, .Debug :
                    Link (destination: URL(string: "itms-beta://beta.itunes.apple.com/v1/app/1635319193")!) {
                        Text("前往TestFlight更新")
                    }
                    .padding(.top)
                case .AppStore:
                    Link (destination: URL(string: "itms-apps://apps.apple.com/us/app/原神披萨小助手/id1635319193")!) {
                        Text("前往App Store更新")
                    }
                    .padding(.top)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle(isJustUpdated ? "感谢您更新到最新版本" : "发现新版本")
        .navigationBarTitleDisplayMode(.large)
        .onAppear(perform: checkNewestVersion)
    }

    func checkNewestVersion() {
        DispatchQueue.global(qos: .default).async {
            switch AppConfig.appConfiguration {
            case .AppStore:
                API.HomeAPIs.fetchNewestVersion(isBeta: false) { result in
                    self.newestVersionInfos = result
                    guard let newestVersionInfos = newestVersionInfos else {
                        return
                    }
                    if buildVersion >= newestVersionInfos.buildVersion {
                        isJustUpdated = true
                    }
                }
            case .Debug, .TestFlight:
                API.HomeAPIs.fetchNewestVersion(isBeta: true) { result in
                    self.newestVersionInfos = result
                    guard let newestVersionInfos = newestVersionInfos else {
                        return
                    }
                    if buildVersion >= newestVersionInfos.buildVersion {
                        isJustUpdated = true
                    }
                }
            }
        }
    }

    func getLocalizedUpdateInfos(meta: NewestVersion) -> [String] {
        switch Locale.current.languageCode {
        case "zh":
            return meta.updates.zhcn
        case "en":
            return meta.updates.en
        case "ja":
            return meta.updates.ja
        case "fr":
            return meta.updates.fr
        default:
            return meta.updates.en
        }
    }
}
