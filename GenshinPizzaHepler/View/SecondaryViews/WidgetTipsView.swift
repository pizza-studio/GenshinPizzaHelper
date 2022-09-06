//
//  WidgetTipsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/6.
//

import SwiftUI

struct WidgetTipsView: View {
    var body: some View {
        NavigationView {
            List {
                Section (header: Text("如何配置小组件？")) {
                    Label("长按小组件，选择编辑\"原神披萨助手\"", systemImage: "1.circle")
                    Label("根据提示选择设置项或启用/关闭功能", systemImage: "2.circle")
                }

                Section (header: Text("如何添加小组件？")) {
                    NavigationLink(destination: WebBroswerView(url: "https://support.apple.com/guide/iphone/iphb8f1bf206/").navigationTitle("如何添加小组件？")) {
                        Label("关于如何添加小组件，请参考Apple支持文档", systemImage: "safari")
                    }
                    Label("如果您未能在小组件选单内找到本软件的小组件，请重启并等待十分钟后再尝试添加小组件", systemImage: "exclamationmark.circle")
                }
            }
        }
    }
}
