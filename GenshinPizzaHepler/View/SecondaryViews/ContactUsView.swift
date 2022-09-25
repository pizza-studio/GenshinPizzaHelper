//
//  ContactUsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/29.
//  联系我们View

import SwiftUI

struct ContactUsView: View {
    @State private var isHakubillDetailShow = false
    @State private var isLavaDetailShow = false

    var body: some View {
        List {
            // developer - lava
            Section (header: Text("开发者")) {
                HStack {
                    Image("avatar.lava")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text("Lava")
                            .bold()
                            .padding(.vertical, 5)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isLavaDetailShow ? 90 : 0))
                }
                .onTapGesture {
                    simpleTaptic(type: .light)
                    withAnimation() {
                        isLavaDetailShow.toggle()
                    }
                }
                if isLavaDetailShow {
                    Link(destination: URL(string: "mailto:daicanglong@gmail.com")!) {
                        Label {
                            Text("daicanglong@gmail.com")
                        } icon: {
                            Image("email")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(destination: URL(string: "https://space.bilibili.com/13079935")!) {
                        Label {
                            Text("Bilibili主页")
                        } icon: {
                            Image("bilibili")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(destination: URL(string: "https://github.com/CanglongCl")!) {
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
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text("水里的碳酸钙")
                            .bold()
                            .padding(.vertical, 5)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isHakubillDetailShow ? 90 : 0))
                }
                .onTapGesture {
                    simpleTaptic(type: .light)
                    withAnimation() {
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
                    Link(destination: URL(string: "https://space.bilibili.com/158463764")!) {
                        Label {
                            Text("Bilibili主页")
                        } icon: {
                            Image("bilibili")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(destination: URL(string: "https://github.com/Bill-Haku")!) {
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
            Section(header: Text("用户交流群")) {
                Link(destination: URL(string: "mqqapi://card/show_pslcard?src_type=internal&version=1&card_type=group&uin=813912474")!) {
                    Label {
                        Text("QQ群1: 813912474")
                    } icon: {
                        Image("qq")
                            .resizable()
                            .scaledToFit()
                    }
                }

                Link(destination: URL(string: "mqqapi://card/show_pslcard?src_type=internal&version=1&card_type=group&uin=829996515")!) {
                    Label {
                        Text("QQ群2: 829996515")
                    } icon: {
                        Image("qq")
                            .resizable()
                            .scaledToFit()
                    }
                }

                Link(destination: URL(string: "https://discord.gg/g8nCgKsaMe")!) {
                    Label {
                        Text("Discord频道: Genshin Pizza Helper")
                    } icon: {
                        Image("discord")
                            .resizable()
                            .scaledToFit()
                    }
                }
            }

            // special thanks
            Section(header: Text("翻译提供")) {
                Label {
                    HStack {
                        Text("Lava")
                        Spacer()
                        Text("英语")
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
                        Text("日语 英语")
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
                        Text("Qi")
                        Spacer()
                        Text("法语")
                            .foregroundColor(.gray)
                    }
                } icon: {
                    Image("avatar.qi")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
            Section(header: Text("特别鸣谢")) {
                Link(destination: URL(string: "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=2251435011")!) {
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
            }
        }
        .navigationTitle("开发者与联系方式")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CaptionLabelStyle : LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            configuration.title
        }
    }
}
