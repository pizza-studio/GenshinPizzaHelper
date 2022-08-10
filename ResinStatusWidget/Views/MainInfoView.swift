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

    var body: some View {
        
        let transformerCompleted: Bool = userData.transformerInfo.isComplete && userData.transformer.obtained
        let anyToNotice: Bool = (userData.resinInfo.isFull || userData.homeCoinInfo.isFull || userData.expeditionInfo.isAllCompleted || transformerCompleted)

        VStack(spacing: 4){
            ResinView(currentResin: userData.currentResin)

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
                RecoveryTimeText(recoveryTimeDeltaInt: userData.resinInfo.recoveryTime.second)
            }
            .frame(maxWidth: 130)
        }
    }
}
