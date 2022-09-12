//
//  LockScreenResinWidgetRectangular.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/12.
//

import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct LockScreenResinWidgetRectangular: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: FetchResult

    var body: some View {
        switch result {
        case .success(let data):
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("\(data.resinInfo.currentResin)")
                            .font(.system(size: 30, design: .rounded))
                        Text("\(Image("icon.resin"))")
                            .font(.system(size: 20, design: .rounded))
                    }
                    .widgetAccentable()
                    if data.resinInfo.isFull {
                        Text("已回满")
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text("\(data.resinInfo.recoveryTime.completeTimePointFromNow()) 回满")
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
            }
        case .failure(_):
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("\(Image(systemName: "ellipsis"))")
                            .font(.system(size: 30, design: .rounded))
                        Text("\(Image("icon.resin"))")
                            .font(.system(size: 20, design: .rounded))
                    }
                    .widgetAccentable()
                    Text(Image("icon.resin"))
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
    }
}



