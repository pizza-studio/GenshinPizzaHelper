//
//  WidgetTipsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/6.
//

import SwiftUI

struct WidgetTipsView: View {
    @Binding var isSheetShow: Bool

    var body: some View {
        NavigationView {
            List {
                Section (header: Text("如何配置小组件和修改小组件背景？").textCase(.none)) {
                    Label("长按小组件，选择编辑\"原神披萨小助手\"", systemImage: "1.circle")
                        .padding(.vertical)
                    Label("根据提示选择设置项或启用/关闭功能或修改背景", systemImage: "2.circle")
                        .padding(.vertical)
                }

                Section (header: Text("如何添加小组件？").textCase(.none)) {
                    NavigationLink(destination: WebBroswerView(url: "https://support.apple.com/HT207122").navigationTitle("如何添加小组件？").navigationBarTitleDisplayMode(.inline)) {
                        Label("关于如何添加小组件，请参考Apple支持文档", systemImage: "safari")
                            .padding(.vertical)
                    }
                    Label("如果您未能在小组件选单内找到本软件的小组件，请重启并等待十分钟后再尝试添加小组件", systemImage: "exclamationmark.circle")
                        .padding(.vertical)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        isSheetShow.toggle()
                    }
                }
            }
            .navigationTitle("小组件使用提示")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
