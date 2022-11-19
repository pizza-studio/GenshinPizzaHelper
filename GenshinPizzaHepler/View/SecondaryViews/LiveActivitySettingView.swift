//
//  LiveActivitySettingView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/11/19.
//

import SwiftUI

struct LiveActivitySettingView: View {
    @AppStorage("autoDeliveryResinTimerLiveActivity") var autoDeliveryResinTimerLiveActivity: Bool = false
    var body: some View {
        if #available(iOS 16.1, *) {
            Section {
                Toggle("自动启用树脂计时器", isOn: $autoDeliveryResinTimerLiveActivity.animation())
//                if autoDeliveryResinTimerLiveActivity {
//                    NavigationLink("树脂计时器设置") {
//                        LiveActivitySettingDetailView()
//                    }
//                }
            } footer: {
                Text("若开启，在退出本App时会自动启用一个“实时活动”树脂计时器。您也可以在“概览”页长按某个账号的卡片手动开启。")
            }
        }
    }
}

//struct LiveActivitySettingDetailView: View {
//    @AppStorage("resinTimerLiveActivityShowAccountName") var resinTimerLiveActivityShowAccountName: Bool = false
//
//    var body: some View {
//        NavigationView {
//            List {
//                Toggle("显示账号名称", isOn: $resinTimerLiveActivityShowAccountName.animation())
//            }
//            .navigationTitle("树脂计时器设置")
//        }
//    }
//}
