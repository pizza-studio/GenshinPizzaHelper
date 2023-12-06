//
//  LockScreenHomeCoinWidgetCorner.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/12.
//

import HoYoKit
import SwiftUI

// MARK: - LockScreenExpeditionWidgetCorner

@available(iOSApplicationExtension 16.0, *)
struct LockScreenExpeditionWidgetCorner: View {
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode

    let result: Result<any DailyNote, any Error>

    var text: String {
        switch result {
        case let .success(data):
            let timeDescription: String = {
                if data.expeditionInformation.allCompleted {
                    return "已全部完成".localized
                } else {
                    if let expeditionInformation = data.expeditionInformation as? GeneralDailyNote
                        .ExpeditionInformation {
                        return formatter.string(from: expeditionInformation.expeditions.map(\.finishTime).max()!)
                    } else {
                        return ""
                    }
                }
            }()
            return "\(data.expeditionInformation.ongoingExpeditionCount)/\(data.expeditionInformation.maxExpeditionsCount) \(timeDescription)"
        case .failure:
            return "app.dailynote.card.expedition.label".localized
        }
    }

    var body: some View {
        Image("icon.expedition")
            .resizable()
            .scaledToFit()
            .padding(3.5)
            .widgetLabel(text)
    }
}

private let formatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .short
    fmt.timeStyle = .short
    return fmt
}()
