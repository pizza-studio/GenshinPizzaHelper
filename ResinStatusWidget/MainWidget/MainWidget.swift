//
//  WidgetView.swift
//  WidgetView
//
//  Created by 戴藏龙 on 2022/7/13.
//  Widget主View

import HoYoKit
import SwiftUI
import WidgetKit

// MARK: - MainWidget

struct MainWidget: Widget {
    let kind: String = "WidgetView"

    var body: some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return configuration
                .containerBackgroundRemovable(false)
        } else {
            return configuration
        }
    }

    var configuration: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectAccountIntent.self,
            provider: MainWidgetProvider()
        ) { entry in
            WidgetViewEntryView(entry: entry)
        }
        .configurationDisplayName("widget.status.title")
        .description("widget.status.enquiry.title")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - WidgetViewEntryView

struct WidgetViewEntryView: View {
    @Environment(\.widgetFamily)
    var family: WidgetFamily
    let entry: MainWidgetProvider.Entry

    var result: Result<any DailyNote, any Error> { entry.result }
    var viewConfig: WidgetViewConfiguration { entry.viewConfig }
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

    @ViewBuilder
    var body: some View {
        ZStack {
            if #available(iOS 17, *) {
            } else {
                WidgetBackgroundView(
                    background: viewConfig.background,
                    darkModeOn: viewConfig.isDarkModeOn
                )
            }
            switch result {
            case let .success(dailyNote):
                WidgetMainView(
                    entry: entry,
                    dailyNote: dailyNote,
                    viewConfig: viewConfig,
                    accountName: accountName
                )
            case let .failure(error):
                WidgetErrorView(
                    error: error,
                    message: viewConfig.noticeMessage ?? ""
                )
            }
        }
        .widgetURL(url)
        .myContainerBackground(viewConfig: viewConfig)
    }
}

extension View {
    fileprivate func myContainerBackground(viewConfig: WidgetViewConfiguration) -> some View {
        modifier(ContainerBackgroundModifier(viewConfig: viewConfig))
    }

    @available(iOSApplicationExtension 17.0, *)
    fileprivate func containerBackgroundStandbyDetector(viewConfig: WidgetViewConfiguration) -> some View {
        modifier(ContainerBackgroundStandbyDetector(viewConfig: viewConfig))
    }
}

// MARK: - ContainerBackgroundModifier

private struct ContainerBackgroundModifier: ViewModifier {
    var viewConfig: WidgetViewConfiguration

    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.containerBackgroundStandbyDetector(viewConfig: viewConfig)
        } else {
            content
        }
    }
}

// MARK: - ContainerBackgroundStandbyDetector

@available(iOSApplicationExtension 17.0, *)
private struct ContainerBackgroundStandbyDetector: ViewModifier {
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode: WidgetRenderingMode
    @Environment(\.widgetContentMargins)
    var widgetContentMargins: EdgeInsets

    var viewConfig: WidgetViewConfiguration

    func body(content: Content) -> some View {
        if widgetContentMargins.top < 5 {
            content.containerBackground(for: .widget) {
                WidgetBackgroundView(
                    background: viewConfig.background,
                    darkModeOn: viewConfig.isDarkModeOn
                )
            }
        } else {
            content.padding(-15).containerBackground(for: .widget) {
                WidgetBackgroundView(
                    background: viewConfig.background,
                    darkModeOn: viewConfig.isDarkModeOn
                )
            }
        }
    }
}
