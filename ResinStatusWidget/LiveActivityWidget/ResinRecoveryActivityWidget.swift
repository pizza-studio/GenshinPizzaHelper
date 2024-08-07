//
//  ResinRecoveryActivityWidget.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/11/19.
//

#if canImport(ActivityKit)
import ActivityKit
import AppIntents
import Defaults
import Foundation
import GIPizzaKit
import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct ResinRecoveryActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: ResinRecoveryAttributes
                .self
        ) { context in
            ResinRecoveryActivityWidgetLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemSymbol: .personFill)
                        Text(context.attributes.accountName)
                    }
                    .foregroundColor(Color("textColor.appIconLike"))
                    .font(.caption2)
                    .padding(.leading)
                }
                .contentMargins(.trailing, 15)
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(alignment: .center, spacing: 4) {
                        Image("AppIconSmall")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .frame(width: 15)
                        Text("app.title.full")
                            .foregroundColor(Color("textColor.appIconLike"))
                            .font(.caption2)
                    }
                    .padding(.trailing)
                }
                .contentMargins(.leading, 15)
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        if Date() < context.state.next20ResinRecoveryTime {
                            HStack {
                                Image("树脂")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 40)
                                VStack(alignment: .leading) {
                                    Text("widget.next20Resin:\(context.state.next20ResinCount)")
                                        .font(.caption2)
                                    Text(
                                        timerInterval: Date() ... context.state
                                            .next20ResinRecoveryTime,
                                        countsDown: true
                                    )
                                    .multilineTextAlignment(.leading)
                                    .font(.system(.title2, design: .rounded))
                                    .foregroundColor(
                                        Color("textColor.originResin")
                                    )
                                }
                                .gridColumnAlignment(.leading)
                                .frame(width: 100)
                            }
                        }
                        Spacer()
                        if Date() < context.state
                            .resinRecoveryTime {
                            HStack {
                                Image("浓缩树脂")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 40)
                                VStack(alignment: .leading) {
                                    Text("widget.nextMaxResin")
                                        .font(.caption2)

                                    Text(
                                        timerInterval: Date() ... context.state
                                            .resinRecoveryTime,
                                        countsDown: true
                                    )
                                    .multilineTextAlignment(.leading)
                                    .font(.system(.title2, design: .rounded))
                                    .foregroundColor(
                                        Color("textColor.originResin")
                                    )
                                }
                                .gridColumnAlignment(.leading)
                                .frame(width: 100)
                            }
                        }
                    }
                    .foregroundColor(Color("textColor3"))
                }
            } compactLeading: {
                Image("树脂").resizable().scaledToFit()
            } compactTrailing: {
                if Date() < context.state
                    .next20ResinRecoveryTime {
                    Text(
                        timerInterval: Date() ... context.state
                            .next20ResinRecoveryTime,
                        countsDown: true,
                        showsHours: false
                    )
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .foregroundColor(Color("textColor2"))
                }
            } minimal: {
                Image("树脂").resizable().scaledToFit()
            }
        }
    }
}

@available(iOS 16.1, *)
struct ResinRecoveryActivityWidgetLockScreenView: View {
    @State
    var context: ActivityViewContext<ResinRecoveryAttributes>

    @Default(.resinRecoveryLiveActivityBackgroundOptions)
    var resinRecoveryLiveActivityBackgroundOptions: [String]

    var useNoBackground: Bool { context.state.background == .noBackground }

    var body: some View {
        let mainContent = contentView
        #if !os(watchOS)
            .background {
                switch context.state.background {
                case .random:
                    Image(NameCard.random.fileName)
                        .resizable()
                        .scaledToFill()
                    Color.black
                        .opacity(0.3)
                case .customize:
                    let chosenCardBackgrounds = NameCard.allLegalCases.compactMap { card in
                        resinRecoveryLiveActivityBackgroundOptions.contains(card.fileName) ? card
                            : nil
                    }
                    let randomCardBg = chosenCardBackgrounds.randomElement() ?? .defaultValue
                    Image(randomCardBg.fileName)
                        .resizable()
                        .scaledToFill()
                    Color.black
                        .opacity(0.3)
                case .noBackground:
                    EmptyView()
                }
            }
        #endif
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .activityBackgroundTint(.clear)
        if #available(iOS 17, *) {
            Button(intent: ResinTimerRerenderIntent()) {
                mainContent
            }
            .buttonStyle(.plain)
            .ignoresSafeArea()
        } else {
            mainContent
        }
    }

    @ViewBuilder
    var contentView: some View {
        HStack {
            Grid(verticalSpacing: 7) {
                if #available(iOS 17, *) {
                    GridRow {
                        Image("树脂")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 38)
                        VStack(alignment: .leading) {
                            Text("widget.currentResin")
                                .font(.caption2)
                            HStack(alignment: .lastTextBaseline, spacing: 0) {
                                Text(verbatim: "\(context.state.currentResin)")
                                    .font(.system(.title2, design: .rounded))
                                Text(verbatim: " / \(ResinInfo.defaultMaxResin)")
                                    .font(.caption)
                            }
                        }
                        .gridColumnAlignment(.leading)
                    }
                } else {
                    if context.state.showNext20Resin,
                       Date() < context.state.next20ResinRecoveryTime {
                        GridRow {
                            Image("树脂")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 38)
                            VStack(alignment: .leading) {
                                Text("widget.next20Resin:\(context.state.next20ResinCount)")
                                    .font(.caption2)
                                Text(
                                    timerInterval: Date() ... context.state
                                        .next20ResinRecoveryTime,
                                    countsDown: true
                                )
                                .multilineTextAlignment(.leading)
                                .font(.system(.title2, design: .rounded))
                            }
                            .gridColumnAlignment(.leading)
                        }
                    }
                }
                if Date() < context.state
                    .resinRecoveryTime {
                    GridRow {
                        Image("浓缩树脂")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 35)
                        VStack(alignment: .leading) {
                            Text("widget.nextMaxResin")
                                .font(.caption2)
                            Text(
                                timerInterval: Date() ... context.state
                                    .resinRecoveryTime,
                                countsDown: true
                            )
                            .multilineTextAlignment(.leading)
                            .font(.system(.title2, design: .rounded))
                        }
                        .gridColumnAlignment(.leading)
                        //                    .frame(width: 140)
                    }
                }
                if context.state.showExpedition,
                   let time = context.state.expeditionAllCompleteTime,
                   Date() < time {
                    GridRow {
                        Image("派遣探索")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 29)
                        VStack(alignment: .leading) {
                            Text("widget.expedition.timeToAllCompletion")
                                .font(.caption2)
                            Text(
                                timerInterval: Date() ... time,
                                countsDown: true
                            )
                            .multilineTextAlignment(.leading)
                            .font(.system(.title2, design: .rounded))
                        }
                        .gridColumnAlignment(.leading)
//                        .frame(width: 140)
                    }
                }
            }
            Spacer()
            VStack {
                Spacer()
                if #available(iOS 17, *) {
                    Button(intent: ResinTimerRefreshIntent()) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text(context.attributes.accountName)
                            Image(systemSymbol: .arrowTriangle2CirclepathCircle)
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.footnote)
                } else {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemSymbol: .personFill)
                        Text(context.attributes.accountName)
                    }
                    .font(.footnote)
                    .padding(.top, 3)
                    .padding(.leading, 3)
                }
            }
        }
        .shadow(radius: useNoBackground ? 0 : 0.8)
        .foregroundColor(useNoBackground ? .primary : Color("textColor3"))
        .padding()
    }
}

@available(iOSApplicationExtension 16.1, iOS 16.1, *)
struct ResinTimerRefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"

    func perform() async throws -> some IntentResult {
        let activities = ResinRecoveryActivityController.shared.currentActivities
        let accounts = AccountModel.shared.fetchAccountConfigs()
        await withThrowingTaskGroup(of: Void.self) { taskGroup in
            activities.forEach { activity in
                taskGroup.addTask {
                    guard let account = accounts.first(where: { account in
                        account.safeUuid == activity.attributes.accountUUID
                    }) else { return }
                    let result = try await account.dailyNote()
                    ResinRecoveryActivityController.shared.updateResinRecoveryTimerActivity(for: account, data: result)
                }
            }
        }
        return .result()
    }
}

// MARK: - ResinTimerRerenderIntent

@available(iOSApplicationExtension 16.1, iOS 16.1, *)
struct ResinTimerRerenderIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"

    func perform() async throws -> some IntentResult {
        let activities = ResinRecoveryActivityController.shared.currentActivities
        activities.forEach { activity in
            Task {
                await activity.update(using: activity.contentState)
            }
        }
        return .result()
    }
}

#endif

// MARK: - ResinTimerRefreshIntent
