//
//  ContactUsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/29.
//  联系我们View

import SFSafeSymbols
import SwiftUI

// MARK: - ContactUsView

struct ContactUsView: View {
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
            // developer - pizza studio
            Section(header: Text("settings.misc.devCrew")) {
                HStack {
                    Image("AppIconHD")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("Pizza Studio")
                            .bold()
                            .padding(.vertical, 5)
                    }
                    Spacer()
                    Image(systemSymbol: .chevronRight)
                        .rotationEffect(.degrees(isPizzaStudioDetailShow ? 90 : 0))
                }
                .onTapGesture {
                    simpleTaptic(type: .light)
                    withAnimation {
                        isPizzaStudioDetailShow.toggle()
                    }
                }
                if isPizzaStudioDetailShow {
                    Link(destination: URL(string: "https://pizzastudio.org")!) {
                        Label {
                            Text("官方网站")
                        } icon: {
                            Image("homepage")
                                .resizable()
                                .scaledToFit()
                        }
                    }

                    Link(
                        destination: URL(
                            string: "mailto:contact@pizzastudio.org"
                        )!
                    ) {
                        Label {
                            Text("contact@pizzastduio.org")
                        } icon: {
                            Image("email")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://github.com/pizza-studio"
                        )!
                    ) {
                        Label {
                            Text("GitHub主页")
                        } icon: {
                            Image("github")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    if Bundle.main.preferredLocalizations.first == "ja" {
                        Link(
                            destination: URL(string: "https://twitter.com/@PizzaStudio_jp")!
                        ) {
                            Label {
                                Text("官方X（Twitter）账号")
                            } icon: {
                                Image("twitter")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    }
                }
            }
            // developer - lava
            Section {
                HStack {
                    Image("avatar.lava")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("Lava")
                            .bold()
                            .padding(.vertical, 5)
                    }
                    Spacer()
                    Image(systemSymbol: .chevronRight)
                        .rotationEffect(.degrees(isLavaDetailShow ? 90 : 0))
                }
                .onTapGesture {
                    simpleTaptic(type: .light)
                    withAnimation {
                        isLavaDetailShow.toggle()
                    }
                }
                if isLavaDetailShow {
                    Link(
                        destination: URL(
                            string: "mailto:daicanglong@gmail.com"
                        )!
                    ) {
                        Label {
                            Text("daicanglong@gmail.com")
                        } icon: {
                            Image("email")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://space.bilibili.com/13079935"
                        )!
                    ) {
                        Label {
                            Text("Bilibili主页")
                        } icon: {
                            Image("bilibili")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://github.com/CanglongCl"
                        )!
                    ) {
                        Label {
                            Text("GitHub主页")
                        } icon: {
                            Image("github")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }
            // developer - hakubill
            Section {
                HStack {
                    Image("avatar.hakubill")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("水里的碳酸钙")
                            .bold()
                            .padding(.vertical, 5)
                    }
                    Spacer()
                    Image(systemSymbol: .chevronRight)
                        .rotationEffect(.degrees(isHakubillDetailShow ? 90 : 0))
                }
                .onTapGesture {
                    simpleTaptic(type: .light)
                    withAnimation {
                        isHakubillDetailShow.toggle()
                    }
                }
                if isHakubillDetailShow {
                    Link(destination: URL(string: "https://hakubill.tech")!) {
                        Label {
                            Text("个人主页")
                        } icon: {
                            Image("homepage")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(destination: URL(string: "mailto:i@hakubill.tech")!) {
                        Label {
                            Text("i@hakubill.tech")
                        } icon: {
                            Image("email")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: isInstallation(urlString: "twitter://") ?
                            URL(
                                string: "twitter://user?id=890517369637847040"
                            )! :
                            URL(string: "https://twitter.com/Haku_Bill")!
                    ) {
                        Label {
                            Text("Twitter主页")
                        } icon: {
                            Image("twitter.old")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://www.youtube.com/channel/UC0ABPKMmJa2hd5nNKh5HGqw"
                        )!
                    ) {
                        Label {
                            Text("YouTube频道")
                        } icon: {
                            Image("youtube")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://space.bilibili.com/158463764"
                        )!
                    ) {
                        Label {
                            Text("Bilibili主页")
                        } icon: {
                            Image("bilibili")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://github.com/Bill-Haku"
                        )!
                    ) {
                        Label {
                            Text("GitHub主页")
                        } icon: {
                            Image("github")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }
            // developer - ShikiSuen
            Section {
                HStack {
                    Image("avatar.shikisuen")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("Shiki Suen (孙志贵)")
                            .bold()
                            .padding(.vertical, 5)
                    }
                    Spacer()
                    Image(systemSymbol: .chevronRight)
                        .rotationEffect(.degrees(isShikiDetailShow ? 90 : 0))
                }
                .onTapGesture {
                    simpleTaptic(type: .light)
                    withAnimation {
                        isShikiDetailShow.toggle()
                    }
                }
                if isShikiDetailShow {
                    Link(
                        destination: URL(string: "https://shikisuen.gitee.io/")!
                    ) {
                        Label {
                            Text("个人主页")
                        } icon: {
                            Image("homepage")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(destination: URL(string: "mailto:shikisuen@pm.me")!) {
                        Label {
                            Text("shikisuen@pm.me")
                        } icon: {
                            Image("email")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: isInstallation(urlString: "twitter://") ?
                            URL(
                                string: "twitter://user?id=176288731"
                            )! :
                            URL(string: "https://twitter.com/ShikiSuen")!
                    ) {
                        Label {
                            Text("Twitter主页")
                        } icon: {
                            Image("twitter.old")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://space.bilibili.com/911304"
                        )!
                    ) {
                        Label {
                            Text("Bilibili主页")
                        } icon: {
                            Image("bilibili")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://github.com/ShikiSuen"
                        )!
                    ) {
                        Label {
                            Text("GitHub主页")
                        } icon: {
                            Image("github")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }

            // app contact
            Section(
                header: Text("用户交流群"),
                footer: Text(groupFooterText).textCase(.none)
            ) {
                Menu {
                    Link(
                        destination: URL(
                            string: "https://pd.qq.com/s/9z504ipbc"
                        )!
                    ) {
                        Label {
                            Text("加入QQ频道")
                        } icon: {
                            Image("qq.circle")
                                .resizable()
                                .scaledToFit()
                        }
                    }

                    Link(
                        destination: URL(
                            string: "mqqapi://card/show_pslcard?src_type=internal&version=1&card_type=group&uin=813912474"
                        )!
                    ) {
                        Label {
                            Text("about.group.qq.1st") + Text("813912474")
                        } icon: {
                            Image("qq")
                                .resizable()
                                .scaledToFit()
                        }
                    }

                    Link(
                        destination: URL(
                            string: "mqqapi://card/show_pslcard?src_type=internal&version=1&card_type=group&uin=829996515"
                        )!
                    ) {
                        Label {
                            Text("about.group.qq.2nd") + Text("829996515")
                        } icon: {
                            Image("qq")
                                .resizable()
                                .scaledToFit()
                        }
                    }

                    Link(
                        destination: URL(
                            string: "mqqapi://card/show_pslcard?src_type=internal&version=1&card_type=group&uin=736320270"
                        )!
                    ) {
                        Label {
                            Text("about.group.qq.3rd") + Text("736320270")
                        } icon: {
                            Image("qq")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } label: {
                    Label {
                        Text("加入QQ群")
                    } icon: {
                        Image("qq")
                            .resizable()
                            .scaledToFit()
                    }
                }

                Link(
                    destination: URL(string: "https://discord.gg/g8nCgKsaMe")!
                ) {
                    Label {
                        Text("加入Discord服务器")
                    } icon: {
                        Image("discord")
                            .resizable()
                            .scaledToFit()
                    }
                }

                if Bundle.main.preferredLocalizations.first != "ja" {
                    Menu {
                        Link(
                            destination: URL(
                                string: "https://t.me/ophelper_zh"
                            )!
                        ) {
                            Label {
                                Text("中文频道")
                            } icon: {
                                Image("telegram")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }

                        Link(
                            destination: URL(
                                string: "https://t.me/ophelper_en"
                            )!
                        ) {
                            Label {
                                Text("English Channel")
                            } icon: {
                                Image("telegram")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }

                        Link(
                            destination: URL(
                                string: "https://t.me/ophelper_ru"
                            )!
                        ) {
                            Label {
                                Text("русскоязычный канал")
                            } icon: {
                                Image("telegram")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    } label: {
                        Label {
                            Text("加入Telegram频道")
                        } icon: {
                            Image("telegram")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }

            // special thanks
            Section(header: Text("翻译提供")) {
                Label {
                    HStack {
                        Text("Lava")
                        Spacer()
                        Text("英文")
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
                        Text("水里的碳酸钙")
                        Spacer()
                        Text("日文".localized + " & " + "英文".localized)
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
                        Text("ShikiSuen")
                        Spacer()
                        Text("繁体中文".localized + " & " + "日文".localized)
                            .foregroundColor(.gray)
                    }
                } icon: {
                    Image("avatar.shikisuen")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
                Menu {
                    Link(
                        destination: isInstallation(urlString: "twitter://") ?
                            URL(
                                string: "twitter://user?id=1593423596545724416"
                            )! :
                            URL(string: "https://twitter.com/hutao_hati")!
                    ) {
                        Label {
                            Text("Twitter主页")
                        } icon: {
                            Image("twitter.old")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://youtube.com/c/hutao_taotao"
                        )!
                    ) {
                        Label {
                            Text("YouTube频道")
                        } icon: {
                            Image("youtube")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://www.tiktok.com/@taotao_hoyo"
                        )!
                    ) {
                        Label {
                            Text("TikTok")
                        } icon: {
                            Image("tiktok")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } label: {
                    Label {
                        HStack {
                            Text("たお👻🍑")
                            Spacer()
                            Text("日文")
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
                        Text("Qi")
                        Spacer()
                        Text("法文")
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
                            Text("VK")
                        } icon: {
                            Image("vk")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } label: {
                    Label {
                        HStack {
                            Text("Art34222")
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
                            Text("Facebook主页")
                        } icon: {
                            Image("facebook")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } label: {
                    Label {
                        HStack {
                            Text("Ngô Phi Phương")
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
                Link(destination: URL(string: "https://chat.openai.com/chat")!) {
                    Label {
                        HStack {
                            Text("ChatGPT")
                            Spacer()
                            Text("繁体中文")
                                .foregroundColor(.gray)
                        }
                    } icon: {
                        Image("chatgpt")
                            .resizable()
                            .foregroundColor(Color(UIColor(
                                red: 117 / 255,
                                green: 168 / 255,
                                blue: 156 / 255,
                                alpha: 1
                            )))
                            .scaledToFit()
                            .clipShape(Circle())
                    }
                }
            }
            Section(header: Text("特别鸣谢")) {
                Menu {
                    Link(
                        destination: URL(
                            string: "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=2251435011"
                        )!
                    ) {
                        Label {
                            Text("QQ")
                        } icon: {
                            Image("qq")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } label: {
                    Label {
                        HStack {
                            Text("郁离居士")
                            Spacer()
                            Text("图片素材制作")
                                .foregroundColor(.gray)
                        }
                    } icon: {
                        Image("avatar.jushi")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    }
                }
                Label {
                    HStack {
                        Text("Xinzoruo (心臓弱眞君)")
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
        .sectionSpacing(UIFont.systemFontSize)
        .navigationTitle("开发者与联系方式")
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
    private var isHakubillDetailShow = false
    @State
    private var isLavaDetailShow = false
    @State
    private var isShikiDetailShow = false
    @State
    private var isPizzaStudioDetailShow = true
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
