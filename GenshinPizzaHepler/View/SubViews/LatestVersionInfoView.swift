//
//  LatestVersionInfoView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/27.
//

import Defaults
import GIPizzaKit
import StoreKit
import SwiftUI

struct LatestVersionInfoView: View {
    @Binding
    var sheetType: ContentViewSheetType?
    @Binding
    var newestVersionInfos: NewestVersion?
    @Binding
    var isJustUpdated: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text(newestVersionInfos?.shortVersion ?? "Loading")
                            .font(.largeTitle).bold() +
                            Text(
                                " (\(String(newestVersionInfos?.buildVersion ?? -1)))"
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Image("AppIconHD")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                    }
                    Divider()
                        .padding(.bottom)
                    if !getLocalizedNoticeInfos(meta: newestVersionInfos!)
                        .isEmpty {
                        Text("app.update.announcement.title")
                            .bold()
                            .font(.title2)
                            .padding(.vertical, 2)
                        ForEach(
                            getLocalizedNoticeInfos(meta: newestVersionInfos!),
                            id: \.self
                        ) { item in
                            Text(verbatim: "∙ ") + Text(item.toAttributedString())
                        }
                        Divider()
                            .padding(.vertical)
                    }
                    Text("app.update.content.title")
                        .bold()
                        .font(.title2)
                        .padding(.vertical, 2)
                    if newestVersionInfos != nil {
                        ForEach(
                            getLocalizedUpdateInfos(meta: newestVersionInfos!),
                            id: \.self
                        ) { item in
                            Text(verbatim: "∙ ") + Text(item.toAttributedString())
                        }
                    } else {
                        Text("Loading")
                    }
                    if !isJustUpdated {
                        switch AppConfig.appConfiguration {
                        case .Debug, .TestFlight:
                            Link(
                                destination: URL(
                                    string: "itms-beta://beta.itunes.apple.com/v1/app/1635319193"
                                )!
                            ) {
                                Text("app.update.goto.tf")
                            }
                            .padding(.top)
                        case .AppStore:
                            Link(
                                destination: URL(
                                    string: "itms-apps://apps.apple.com/us/app/id1635319193"
                                )!
                            ) {
                                Text("app.update.goto.as")
                            }
                            .padding(.top)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationTitle(isJustUpdated ? "app.update.thanks" : "app.update.found")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("latestVersionInfoView.affirmative") {
                        Defaults[.checkedUpdateVersions].append(newestVersionInfos!.buildVersion)
                        UserDefaults.opSuite.synchronize()
                        if isJustUpdated {
                            let showRate = Bool.random()
                            if showRate {
                                DispatchQueue.global()
                                    .asyncAfter(deadline: .now() + 2) {
                                        ReviewHandler.requestReview()
                                    }
                            }
                        }
                        sheetType = nil
                    }
                }
            }
        }
    }

    func getLocalizedUpdateInfos(meta: NewestVersion) -> [String] {
        let locale = Bundle.main.preferredLocalizations.first
        switch locale {
        case "zh-Hans":
            return meta.updates.zhcn
        case "zh-Hant", "zh-HK":
            return meta.updates.zhtw ?? meta.updates.zhcn
        case "en":
            return meta.updates.en
        case "ja":
            return meta.updates.ja
        case "fr":
            return meta.updates.fr
        case "ru":
            return meta.updates.ru ?? meta.updates.en
        default:
            return meta.updates.en
        }
    }

    func getLocalizedNoticeInfos(meta: NewestVersion) -> [String] {
        let locale = Bundle.main.preferredLocalizations.first
        switch locale {
        case "zh-Hans":
            return meta.notice.zhcn
        case "zh-Hant", "zh-HK":
            return meta.notice.zhtw ?? meta.notice.zhcn
        case "en":
            return meta.notice.en
        case "ja":
            return meta.notice.ja
        case "fr":
            return meta.notice.fr
        case "ru":
            return meta.notice.ru ?? meta.notice.en
        default:
            return meta.notice.en
        }
    }
}
