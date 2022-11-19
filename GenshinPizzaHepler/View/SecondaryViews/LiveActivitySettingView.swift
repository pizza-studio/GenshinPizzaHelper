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
                    .disabled(!ResinRecoveryActivityController.shared.allowLiveActivity)
                if !ResinRecoveryActivityController.shared.allowLiveActivity {
                    Button("前往设置开启实时活动功能") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            } footer: {
                if !ResinRecoveryActivityController.shared.allowLiveActivity {
                    Text("实时活动功能未开启，请前往设置开启。")
                } else {
                    Text("若开启，在退出本App时会自动启用一个“实时活动”树脂计时器。您也可以在“概览”页长按某个账号的卡片手动开启。")
                }

            }
        }
    }
}


