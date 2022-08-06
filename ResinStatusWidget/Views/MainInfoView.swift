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
        let resinFull: Bool = userData.currentResin == 160
        let homeCoinFull: Bool = userData.currentHomeCoin == 2400
        let allExpeditionComplete: Bool = userData.currentExpeditionNum == 0
        let transformerCompleted: Bool = userData.transformerTimeSecondInt == 0
        let anyToNotice: Bool = (resinFull || homeCoinFull || allExpeditionComplete || transformerCompleted)

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
                RecoveryTimeText(recoveryTimeDeltaInt: userData.resinRecoveryTimeInt)
            }
            .frame(maxWidth: 130)
        }
    }
}
