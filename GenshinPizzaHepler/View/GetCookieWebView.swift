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
                                        print($0.name, $0.value)
                                        cookie = cookie + $0.name + "=" + $0.value + "; "
                                        dataStore.httpCookieStore.delete($0)
                                    }
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
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                    records.forEach { record in
                        WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                        #if DEBUG
                            print("WKWebsiteDataStore record deleted:", record)
                        #endif
                    }
                }
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.allHTTPHeaderFields = [
            "Host": "m.bbs.mihoyo.com",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Connection": "keep-alive",
            "Accept-Encoding": "gzip, deflate, br",
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 Safari/604.1",
        ]
        let webview = WKWebView()
        webview.configuration.websiteDataStore = dataStore
        webview.load(request)
        return webview
    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: self.url) {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
            request.httpShouldHandleCookies = false 
            request.allHTTPHeaderFields = [
                "Host": "m.bbs.mihoyo.com",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "Accept-Language": "zh-CN,zh-Hans;q=0.9",
                "Connection": "keep-alive",
                "Accept-Encoding": "gzip, deflate, br",
                "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 Safari/604.1",
                "Cookie": ""
            ]
            print(request.description)
            uiView.load(request)
        }
    }
}
