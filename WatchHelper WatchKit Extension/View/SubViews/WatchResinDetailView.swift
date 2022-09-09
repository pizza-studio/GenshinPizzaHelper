//
//  WatchResinDetailView.swift
//  WatchHelper WatchKit Extension
//
//  Created by 戴藏龙 on 2022/9/9.
//

import SwiftUI

struct WatchResinDetailView: View {
    let resinInfo: ResinInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("原粹树脂")
                    .foregroundColor(Color("textColor.originResin"))
                Spacer()
                Image("树脂")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 20)
            }
            Text("\(resinInfo.currentResin)")
                .font(.system(size: 40, design: .rounded))
                .fontWeight(.medium)
            recoveryTimeText()
        }
    }

    @ViewBuilder
    func recoveryTimeText() -> some View {
        if resinInfo.recoveryTime.second != 0 {
            Text(LocalizedStringKey("\(resinInfo.recoveryTime.completeTimePointFromNow!) 回满"))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        } else {
            Text("树脂已全部回满")
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
}

