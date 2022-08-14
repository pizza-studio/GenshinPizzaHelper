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
    let accountName: String?
    let accountNameTest = "我的帐号"
    

    var condensedResin: Int { userData.resinInfo.currentResin / 40 }

    var body: some View {
        
        let transformerCompleted: Bool = userData.transformerInfo.isComplete && userData.transformerInfo.obtained && viewConfig.showTransformer
        let expeditionCompleted: Bool = viewConfig.expeditionViewConfig.noticeExpeditionWhenAllCompleted ? userData.expeditionInfo.allCompleted : userData.expeditionInfo.anyCompleted
        let weeklyBossesNotice: Bool = viewConfig.showWeeklyBosses && !userData.weeklyBossesInfo.isComplete && Calendar.current.isDateInWeekend(Date())
        let dailyTaskNotice: Bool = !userData.dailyTaskInfo.isTaskRewardReceived && (userData.dailyTaskInfo.finishedTaskNum == userData.dailyTaskInfo.totalTaskNum)
        
        // 需要马上上号
        let needToLoginImediately: Bool = (userData.resinInfo.isFull || userData.homeCoinInfo.isFull || expeditionCompleted || transformerCompleted || dailyTaskNotice)
        // 可以晚些再上号，包括每日任务和周本
        let needToLoginSoon: Bool = !userData.dailyTaskInfo.isTaskRewardReceived || weeklyBossesNotice
        
        
        
        VStack(alignment: .leading, spacing: 0) {
//            Spacer()
            if let accountName = accountName {
                
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemName: "person.fill")
                    Text(accountName)
                    
                }
                .font(.footnote)
                .foregroundColor(Color("textColor3"))
                Spacer()
                
            }
            
            
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                
                Text("\(userData.resinInfo.currentResin)")
                    .font(.system(size: 50 , design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Color("textColor3"))
                    .shadow(radius: 1)
                Image("树脂")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 30)
                    .alignmentGuide(.firstTextBaseline) { context in
                        context[.bottom] - 0.17 * context.height
                    }
            }
            Spacer()
            HStack {
                if needToLoginImediately {
                    if needToLoginSoon {
                        Image("exclamationmark.circle.questionmark")
                            .foregroundColor(Color("textColor3"))
                            .font(.title3)
                    } else {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(Color("textColor3"))
                            .font(.title3)
                    }
                } else if needToLoginSoon {
                    Image("hourglass.circle.questionmark")
                        .foregroundColor(Color("textColor3"))
                        .font(.title3)
                } else {
                    Image(systemName: "hourglass.circle")
                        .foregroundColor(Color("textColor3"))
                        .font(.title3)
                }
                RecoveryTimeText(resinInfo: userData.resinInfo)
            }
//            Spacer()
        }
    }
}

struct preview: PreviewProvider {
    static var previews: some View {
        MainInfo(userData: UserData.defaultData, viewConfig: WidgetViewConfiguration.defaultConfig, accountName: nil)
            .background(LinearGradient(colors: WidgetBackgroundColor.purple.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}
