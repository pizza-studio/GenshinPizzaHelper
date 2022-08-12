//
//  DailyTaskInfoBar.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import SwiftUI

struct DailyTaskInfoBar: View {
    let dailyTaskInfo: DailyTaskInfo
    
    var isTaskRewardReceivedImage: Image {
        if !dailyTaskInfo.isTaskRewardReceived {
            if dailyTaskInfo.finishedTaskNum == dailyTaskInfo.totalTaskNum {
                return Image(systemName: "exclamationmark")
            } else {
                return Image(systemName: "questionmark")
            }
        } else  {
            return Image(systemName: "checkmark")
        }
    }
    
    var body: some View {
        
        
        HStack(alignment: .center ,spacing: 8) {
            Image("每日任务")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            
            isTaskRewardReceivedImage
                .resizable()
                .scaledToFit()
                .font(Font.title.bold())
                .overlayRingProgressBar(1.0)
                .frame(width: 15, height: 15)
                .foregroundColor(Color("textColor3"))
            
            HStack(alignment: .lastTextBaseline, spacing:1) {
                Text("\(dailyTaskInfo.finishedTaskNum)")
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
                Text(" / \(dailyTaskInfo.totalTaskNum)")
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
                if !dailyTaskInfo.isTaskRewardReceived && (dailyTaskInfo.finishedTaskNum == dailyTaskInfo.totalTaskNum) {
                    Text("（未领取）")
                        .foregroundColor(Color("textColor3"))
                        .font(.system(.caption, design: .rounded))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                }
            }
        }
    }
}

