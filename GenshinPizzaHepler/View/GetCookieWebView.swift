//
//  GetCookieWebView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/16.
//

import SwiftUI
import WebKit

struct GetCookieWebView: View {
    
    @Binding var isShown: Bool
    @Binding var cookie: String
    let region: Region
    var dataStore: WKWebsiteDataStore = .default()
    
    let cookieKeysToSave: [String] = ["ltoken", "ltuid"]
    
    var url: String {
        switch region {
        case .cn:
            return "https://m.bbs.mihoyo.com/ys/"
        case .global:
            return "https://m.hoyolab.com/#/home"
        }
    }

    var body: some View {
        
        NavigationView {
            CookieGetterWebView(url: url, dataStore: dataStore)
//                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            cookie = ""
                            DispatchQueue.main.async {
                                dataStore.httpCookieStore.getAllCookies { cookies in
                                    cookies.forEach {
                                        if cookieKeysToSave.contains($0.name) {
                                            cookie = cookie + $0.name + "=" + $0.value + "; "
                                        }
                                        dataStore.httpCookieStore.delete($0)
                                    }
                                    print("cookie 获取完成")
                                }
                                
                                isShown.toggle()
                            }
                            
                            
                        }
                    }
                }
                .navigationTitle("请登录")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CookieGetterWebView: UIViewRepresentable {
    var url: String = ""
    let dataStore: WKWebsiteDataStore
    
    
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: self.url)
        else {
            return WKWebView()
        }
        let request = URLRequest(url: url)
        let webview = WKWebView()
        webview.configuration.websiteDataStore = dataStore
        webview.load(request)
        return webview
    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: self.url) {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            print(request.description)
            uiView.load(request)
        }
    }
}
