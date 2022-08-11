//
//  MainInfoView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation
import SwiftUI

struct MainInfo: View {
    let userData: UserData
    let viewConfig: WidgetViewConfiguration

    var body: some View {
        
        let transformerCompleted: Bool = userData.transformerInfo.isComplete && userData.transformerInfo.obtained && viewConfig.showTransformer
        let expeditionCompleted: Bool = viewConfig.expeditionViewConfig.noticeExpeditionWhenAllCompleted ? userData.expeditionInfo.allCompleted : userData.expeditionInfo.anyCompleted

        let anyToNotice: Bool = (userData.resinInfo.isFull || userData.homeCoinInfo.isFull || expeditionCompleted || transformerCompleted)

        VStack(spacing: 4){
            ResinView(resinInfo: userData.resinInfo)

            HStack {
                if anyToNotice {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(Color("textColor3"))
                        .font(.title3)
                } else {
                    Image(systemName: "hourglass.circle")
                        .foregroundColor(Color("textColor3"))
                        .font(.title3)
                }
                RecoveryTimeText(resinInfo: userData.resinInfo)
            }
            .frame(maxWidth: 130)
        }
    }
}
