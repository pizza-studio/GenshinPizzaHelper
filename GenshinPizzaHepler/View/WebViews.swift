//
//  SFSafariView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/10.
//

import SwiftUI
import SafariServices
import WebKit

struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {
        return
    }
}

struct WebBroswerView: UIViewRepresentable {
    var url: String = ""
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: self.url)
        else {
            return WKWebView()
        }
        let request = URLRequest(url: url)
        let webview = WKWebView()
        webview.load(request)
        return webview
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: self.url) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

struct UserPolicyView: View {
    @Binding var sheet: SettingsViewSheetType?

    var body: some View {
        NavigationView {
            WebBroswerView(url: "http://zhuaiyuwen.xyz/static/policy.html")
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("拒绝") {
                            exit(1)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("同意") {
                            UserDefaults.standard.setValue(true, forKey: "isPolicyShown")
                            UserDefaults.standard.synchronize()
                            sheet = nil
                        }
                    }
                }
        }
    }
}
