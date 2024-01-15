//
//  GuideVideoLinkView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/6.
//

import SwiftUI

struct GuideVideoLinkView: View {
    var body: some View {
        List {
            Section(header: Text("中文")) {
                Link(destination: (
                    isInstallation(urlString: "bilibili://") ?
                        URL(string: "bilibili://video/BV1fC4y1v7yx")! :
                        URL(
                            string: "https://www.bilibili.com/video/BV1fC4y1v7yx/"
                        )
                )!) {
                    Label {
                        Text("app.open.bilibili")
                    } icon: {
                        Image("bilibili")
                            .resizable()
                            .foregroundColor(.blue)
                            .scaledToFit()
                    }
                }
                Link(
                    destination: URL(
                        string: "https://youtu.be/fS5g-U3E0wI"
                    )!
                ) {
                    Label {
                        Text("app.open.youtube")
                    } icon: {
                        Image("youtube")
                            .resizable()
                            .foregroundColor(.blue)
                            .scaledToFit()
                    }
                }
            }
            Section(header: Text("English")) {
                Link(
                    destination: URL(
                        string: "https://www.youtube.com/watch?v=ox4RZ1VVu18"
                    )!
                ) {
                    Label {
                        Text("app.open.youtube")
                    } icon: {
                        Image("youtube")
                            .resizable()
                            .foregroundColor(.blue)
                            .scaledToFit()
                    }
                }
                Link(destination: (
                    isInstallation(urlString: "bilibili://") ?
                        URL(string: "bilibili://video/BV1BG4y167Dr")! :
                        URL(
                            string: "https://www.bilibili.com/video/BV1BG4y167Dr"
                        )
                )!) {
                    Label {
                        Text("app.open.bilibili")
                    } icon: {
                        Image("bilibili")
                            .resizable()
                            .foregroundColor(.blue)
                            .scaledToFit()
                    }
                }
            }
            Section(header: Text("日本語")) {
                Link(
                    destination: URL(
                        string: "https://youtu.be/a28FbE4qKU0"
                    )!
                ) {
                    Label {
                        Text("app.open.youtube")
                    } icon: {
                        Image("youtube")
                            .resizable()
                            .foregroundColor(.blue)
                            .scaledToFit()
                    }
                }
                Link(destination: (
                    isInstallation(urlString: "bilibili://") ?
                        URL(string: "bilibili://video/BV1eN4y1p7M8")! :
                        URL(
                            string: "https://www.bilibili.com/video/BV1eN4y1p7M8/"
                        )
                )!) {
                    Label {
                        Text("app.open.bilibili")
                    } icon: {
                        Image("bilibili")
                            .resizable()
                            .foregroundColor(.blue)
                            .scaledToFit()
                    }
                }
            }
        }
        .navigationBarTitle("app.introduce.title")
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
}
