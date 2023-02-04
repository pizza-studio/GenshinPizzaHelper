//
//  HelpSheetView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/8.
//  更多页面

import SwiftUI

struct MoreView: View {
    @ObservedObject var viewModel: MoreViewCacheViewModel = MoreViewCacheViewModel()
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: UpdateHistoryInfoView()) {
                    Text("检查更新")
                }
                #if DEBUG
                Button("清空已检查的版本号") {
                    UserDefaults.standard.set([], forKey: "checkedUpdateVersions")
                    UserDefaults.standard.set(0, forKey: "checkedNewestVersion")
                    UserDefaults.standard.synchronize()
                }
                #endif
            }
            Section {
                Link("获取Cookie的脚本", destination: URL(string: "https://www.icloud.com/shortcuts/fe68f22c624949c9ad8959993239e19c")!)
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
            
            Section {
                Button("清空缓存   \(String(format: "%.2f", self.viewModel.fileSize))MB") {
                    self.viewModel.clearImageCache()
                }
            }
        }
        .navigationBarTitle("更多", displayMode: .inline)
    }
}

class MoreViewCacheViewModel: ObservableObject {
    let imageFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Images")
    @Published var fileSize: Double
    
    init() {
        do {
            let fileUrls = try FileManager.default.contentsOfDirectory(atPath: self.imageFolderURL.path)
            self.fileSize = 0.0
            for fileUrl in fileUrls {
                let attributes = try FileManager.default.attributesOfItem(atPath: imageFolderURL.appendingPathComponent(fileUrl).path)
                self.fileSize += attributes[FileAttributeKey.size] as! Double
            }
            self.fileSize = self.fileSize / 1024.0 / 1024.0
        } catch {
            print("error get images size: \(error)")
            self.fileSize = 0.0
        }
    }
    
    func clearImageCache() {
        do {
            let fileUrls = try FileManager.default.contentsOfDirectory(atPath: self.imageFolderURL.path)
            for fileUrl in fileUrls {
                try FileManager.default.removeItem(at: imageFolderURL.appendingPathComponent(fileUrl))
            }
            self.fileSize = 0.0
            print("Image Cache Cleared!")
        } catch {
            print("error: Image Cache Clear:\(error)")
        }
    }
}
