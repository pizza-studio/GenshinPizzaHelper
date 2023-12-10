//
//  LockScreenResinFullTimeWidget.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2022/11/25.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinFullTimeWidget

@available(iOSApplicationExtension 16.0, *)
struct LockScreenResinFullTimeWidget: Widget {
    let kind: String = "LockScreenResinFullTimeWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "的原粹树脂回满时间")
        ) { entry in
            LockScreenResinFullTimeWidgetView(entry: entry)
                .lockscreenContainerBackground { EmptyView() }
        }
        .configurationDisplayName("原粹树脂回满时间")
        .description("展示原粹树脂与恢复到160树脂的时间")
        .supportedFamilies([.accessoryCircular])
        .contentMarginsDisabled()
    }
}

// MARK: - LockScreenResinFullTimeWidgetView

@available(iOS 16.0, *)
struct LockScreenResinFullTimeWidgetView: View {
    @Environment(\.widgetFamily)
    var family: WidgetFamily
    let entry: LockScreenWidgetProvider.Entry

    var result: LockScreenWidgetProvider.Entry.Result { entry.result }
    var accountName: String? { entry.accountName }

    var url: URL? {
        let errorURL: URL = {
            var components = URLComponents()
            components.scheme = "ophelperwidget"
            components.host = "accountSetting"
            components.queryItems = [
                .init(
                    name: "accountUUIDString",
                    value: entry.accountUUIDString
                ),
            ]
            return components.url!
        }()

        switch result {
        case .success:
            return nil
        case .failure:
            return errorURL
        }
    }

    var body: some View {
        Group {
            LockScreenResinFullTimeWidgetCircular(entry: entry, result: result)
        }
        .widgetURL(url)
    }
}
