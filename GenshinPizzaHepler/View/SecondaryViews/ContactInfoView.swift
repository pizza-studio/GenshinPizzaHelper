//
//  ContactInfoView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/29.
//  联系我们View

import SFSafeSymbols
import SwiftUI

// MARK: - ContactInfoView

struct ContactInfoView: View {
    // MARK: Internal

    var groupFooterText: String {
        var text = ""
        if Locale.isUILanguagePanChinese {
            text = "我们推荐您加入QQ频道。QQ群都即将满员，而在频道你可以与更多朋友们交流，第一时间获取来自开发者的消息，同时还有官方消息的转发和其他更多功能！"
        }
        return text
    }

    var body: some View {
        List {
            mainDeveloperTeamSection()

            // app contact
            Section(
                header: Text("contact.group.header"),
                footer: Text(groupFooterText).textCase(.none)
            ) {
                Menu {
                    LinkLabelItem(qqChannel: "9z504ipbc")
                    LinkLabelItem(qqGroup: "813912474", titleOverride: "about.group.qq.1st")
                    LinkLabelItem(qqGroup: "829996515", titleOverride: "about.group.qq.2nd")
                    LinkLabelItem(qqGroup: "736320270", titleOverride: "about.group.qq.3rd")
                } label: {
                    Label {
                        Text("app.contact.joinQQGroup")
                    } icon: {
                        Image("icon.qq")
                            .resizable()
                            .scaledToFit()
                    }
                }

                LinkLabelItem(
                    "sys.contact.discord",
                    imageKey: "icon.discord",
                    url: "https://discord.gg/g8nCgKsaMe"
                )

                if Bundle.main.preferredLocalizations.first != "ja" {
                    Menu {
                        LinkLabelItem(
                            verbatim: "Telegram 中文频道",
                            imageKey: "telegram",
                            url: "https://t.me/ophelper_zh"
                        )
                        LinkLabelItem(
                            verbatim: "Telegram English Channel",
                            imageKey: "telegram",
                            url: "https://t.me/ophelper_en"
                        )
                        LinkLabelItem(
                            verbatim: "Telegram Русскоязычный Канал",
                            imageKey: "telegram",
                            url: "https://t.me/ophelper_ru"
                        )
                    } label: {
                        Label {
                            Text("加入Telegram频道")
                        } icon: {
                            Image("icon.telegram")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }

            // special thanks
            Section(header: Text("contact.translator.header")) {
                Label {
                    HStack {
                        Text(verbatim: "Lava")
                        Spacer()
                        Text("contact.translator.en")
                            .foregroundColor(.gray)
                    }
                } icon: {
                    Image("avatar.lava")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
                Label {
                    HStack {
                        Text("contact.billHaku")
                        Spacer()
                        Text("contact.translator.ja".localized + " & " + "contact.translator.en".localized)
                            .foregroundColor(.gray)
                    }
                } icon: {
                    Image("avatar.hakubill")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
                Label {
                    HStack {
                        Text(verbatim: "Shiki Suen")
                        Spacer()
                        Text("contact.translator.zhtw".localized + " & " + "contact.translator.ja".localized)
                            .foregroundColor(.gray)
                    }
                } icon: {
                    Image("avatar.shikisuen")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
                Menu {
                    LinkLabelItem(twitter: "hutao_hati")
                    LinkLabelItem(youtube: "https://youtube.com/c/hutao_taotao")
                    LinkLabelItem(
                        verbatim: "TikTok Global",
                        imageKey: "icon.tiktok",
                        url: "https://www.tiktok.com/@taotao_hoyo"
                    )
                } label: {
                    Label {
                        HStack {
                            Text("contact.translator.hatti")
                            Spacer()
                            Text("contact.translator.ja")
                                .foregroundColor(.gray)
                        }
                    } icon: {
                        Image("avatar.tao.3")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    }
                }
                Label {
                    HStack {
                        Text(verbatim: "Qi")
                        Spacer()
                        Text("contact.translator.fr")
                            .foregroundColor(.gray)
                    }
                } icon: {
                    Image("avatar.qi")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
                Menu {
                    Link(
                        destination: isInstallation(urlString: "vk://") ?
                            URL(string: "vk://vk.com/arrteem40")! :
                            URL(string: "https://vk.com/arrteem40")!
                    ) {
                        Label {
                            Text(verbatim: "VK")
                        } icon: {
                            Image("icon.vk")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } label: {
                    Label {
                        HStack {
                            Text(verbatim: "Art34222")
                            Spacer()
                            Text("lang.Russian")
                                .foregroundColor(.gray)
                        }
                    } icon: {
                        Image("avatar.Art34222")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    }
                }
                Menu {
                    Link(
                        destination: URL(
                            string: "https://www.facebook.com/ngo.phi.phuongg"
                        )!
                    ) {
                        Label {
                            Text(verbatim: "Facebook")
                        } icon: {
                            Image("icon.facebook")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } label: {
                    Label {
                        HStack {
                            Text(verbatim: "Ngô Phi Phương")
                            Spacer()
                            Text("lang.Vietnamese")
                                .foregroundColor(.gray)
                        }
                    } icon: {
                        Image("avatar.ngo")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    }
                }
            }
            Section(header: Text("donate.specialThanks")) {
                Menu {
                    LinkLabelItem(qqPersonal: "2251435011")
                } label: {
                    Label {
                        HStack {
                            Text(verbatim: "郁离居士")
                            Spacer()
                            Text("contact.thanks.ming")
                                .foregroundColor(.gray)
                        }
                    } icon: {
                        Image("avatar.jushi")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    }
                }
                Menu {
                    LinkLabelItem(twitter: "xinzoruo")
                } label: {
                    Label {
                        HStack {
                            Text(verbatim: "Xinzoruo (心臓弱眞君)")
                            Spacer()
                            Text("Logo")
                                .foregroundColor(.gray)
                        }
                    } icon: {
                        Image("avatar.xinzoruo")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    }
                }
            }
        }
        .navigationTitle("contact.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    func isInstallation(urlString: String?) -> Bool {
        let url = URL(string: urlString!)
        if url == nil {
            return false
        }
        if UIApplication.shared.canOpenURL(url!) {
            return true
        }
        return false
    }

    // MARK: Private

    @State
    private var isPizzaStudioDetailVisible = false
    @State
    private var isLavaDetailVisible = false
    @State
    private var isHakubillDetailVisible = false
    @State
    private var isShikiDetailVisible = false

    private var isJapaneseUI: Bool {
        Bundle.main.preferredLocalizations.first == "ja"
    }

    @ViewBuilder
    private func mainDeveloperTeamSection() -> some View {
        Section(header: Text("sys.contact.title.developer")) {
            // developer - Pizza Studio
            HStack {
                Image("AppIconHD").resizable().clipShape(Circle())
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text(verbatim: "Pizza Studio").bold().padding(.vertical, 5)
                }
                Spacer()
                Image(systemSymbol: .chevronRight)
                    .rotationEffect(.degrees(isPizzaStudioDetailVisible ? 90 : 0))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                simpleTaptic(type: .light)
                withAnimation { isPizzaStudioDetailVisible.toggle() }
            }
            if isPizzaStudioDetailVisible {
                LinkLabelItem(officialWebsite: "https://pizzastudio.org")
                LinkLabelItem(email: "contact@pizzastudio.org")
                LinkLabelItem(github: "pizza-studio")
                if isJapaneseUI {
                    LinkLabelItem(twitter: "PizzaStudio_jp")
                }
            }

            // developer - lava
            HStack {
                Image("avatar.lava").resizable().clipShape(Circle())
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text("sys.contact.lava").bold().padding(.vertical, 5)
                }
                Spacer()
                Image(systemSymbol: .chevronRight)
                    .rotationEffect(.degrees(isLavaDetailVisible ? 90 : 0))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                simpleTaptic(type: .light)
                withAnimation { isLavaDetailVisible.toggle() }
            }
            if isLavaDetailVisible {
                LinkLabelItem(email: "daicanglong@gmail.com")
                LinkLabelItem(bilibiliSpace: "13079935")
                LinkLabelItem(github: "CanglongCl")
            }

            // developer - hakubill
            HStack {
                Image("avatar.hakubill").resizable().clipShape(Circle())
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text("sys.contact.hakubill").bold().padding(.vertical, 5)
                }
                Spacer()
                Image(systemSymbol: .chevronRight)
                    .rotationEffect(.degrees(isHakubillDetailVisible ? 90 : 0))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                simpleTaptic(type: .light)
                withAnimation { isHakubillDetailVisible.toggle() }
            }
            if isHakubillDetailVisible {
                LinkLabelItem(homePage: "https://hakubill.tech")
                LinkLabelItem(email: "i@hakubill.tech")
                LinkLabelItem(twitter: "Haku_Bill")
                LinkLabelItem(youtube: "https://www.youtube.com/channel/UC0ABPKMmJa2hd5nNKh5HGqw")
                LinkLabelItem(bilibiliSpace: "158463764")
                LinkLabelItem(github: "Bill-Haku")
            }

            // developer - ShikiSuen
            Section {
                HStack {
                    Image("avatar.shikisuen").resizable().clipShape(Circle())
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text("Shiki Suen (孙志贵)").bold().padding(.vertical, 5)
                    }
                    Spacer()
                    Image(systemSymbol: .chevronRight)
                        .rotationEffect(.degrees(isShikiDetailVisible ? 90 : 0))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    simpleTaptic(type: .light)
                    withAnimation { isShikiDetailVisible.toggle() }
                }
                if isShikiDetailVisible {
                    LinkLabelItem(neteaseMusic: "60323623")
                    LinkLabelItem(homePage: "https://shikisuen.github.io")
                    LinkLabelItem(email: "shikisuen@yeah.net")
                    LinkLabelItem(twitter: "ShikiSuen")
                    LinkLabelItem(bilibiliSpace: "911304")
                    LinkLabelItem(github: "ShikiSuen")
                }
            }
        }
    }
}

// MARK: - CaptionLabelStyle

private struct CaptionLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            configuration.title
        }
    }
}
