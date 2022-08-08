//
//  HelpSheetView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/8.
//

import SwiftUI

struct HelpSheetView: View {
    @Binding var isShow: Bool

    var body: some View {
        NavigationView {
            List {
                Section {
                    Link("获取Cookie的脚本", destination: URL(string: "https://www.icloud.com/shortcuts/fe68f22c624949c9ad8959993239e19c")!)
                }
                Section {

                }
            }
            .navigationBarTitle("其他信息", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        isShow.toggle()
                    }
                }
            }
        }
    }
}
