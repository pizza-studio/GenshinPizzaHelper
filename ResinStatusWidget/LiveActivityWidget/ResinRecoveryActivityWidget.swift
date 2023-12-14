//
//  ResinRecoveryActivityWidget.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/11/19.
//

#if canImport(ActivityKit)
import ActivityKit
import Defaults
import Foundation
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
                        HStack {
                            Image("树脂")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 40)
                            VStack(alignment: .leading) {
                                let nextCount = String(
                                    format: "widget.next20Resin:%lld",
                                    context.state.next20ResinCount
                                ).localized
                                Text(nextCount)
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
                        Spacer()
                        HStack {
                            Image("浓缩树脂")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 40)
                            VStack(alignment: .leading) {
                                Text("widget.next160Resin")
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
                    .foregroundColor(Color("textColor3"))
                }
            } compactLeading: {
                Image("树脂").resizable().scaledToFit()
            } compactTrailing: {
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
        contentView
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
    }

    @ViewBuilder
    var contentView: some View {
        HStack {
            Grid(verticalSpacing: 7) {
                if context.state.showNext20Resin {
                    GridRow {
                        Image("树脂")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 38)
                        VStack(alignment: .leading) {
                            let nextCount = String(format: "widget.next20Resin:%lld", context.state.next20ResinCount)
                                .localized
                            Text(nextCount)
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
//                        .frame(width: 140)
                    }
                }
                GridRow {
                    Image("浓缩树脂")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 35)
                    VStack(alignment: .leading) {
                        Text("widget.next160Resin")
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
                if context.state.showExpedition, let time = context.state
                    .expeditionAllCompleteTime {
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
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemSymbol: .personFill)
                    Text(context.attributes.accountName)
                }
                .font(.footnote)
                .padding(.top, 3)
                .padding(.leading, 3)
            }
        }
        .shadow(radius: useNoBackground ? 0 : 0.8)
        .foregroundColor(useNoBackground ? .primary : Color("textColor3"))
        .padding()
    }
}
#endif
