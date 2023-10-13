//
//  LockScreenResinWidgetInline.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2022/9/11.
//

import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI

struct LockScreenResinWidgetInline<T>: View
    where T: SimplifiedUserDataContainer {
    let result: SimplifiedUserDataContainerResult<T>

    var body: some View {
        switch result {
        case let .success(data):
            if data.resinInfo.isFull {
                Image(systemSymbol: .moonStarsFill)
            } else {
                Image(systemSymbol: .moonFill)
            }
            Text(
                "\(data.resinInfo.currentResin)  \(data.resinInfo.recoveryTime.describeIntervalShort(finishedTextPlaceholder: "", unisStyle: .brief))"
            )
        // 似乎不能插入自定义的树脂图片，也许以后会开放
//                Image("icon.resin")
        case .failure:
            Image(systemSymbol: .moonFill)
            Text("…")
        }
    }
}
