//
//  ResinRecoveryActivityWidget.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/11/19.
//

import Foundation
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct ResinRecoveryActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ResinRecoveryAttributes.self) { context in
            ResinRecoveryActivityWidgetLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image("树脂").resizable().scaledToFit()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack {
                        Spacer()
                        Text(timerInterval: Date()...context.state.next20ResinRecoveryTime!, countsDown: true)
                            .multilineTextAlignment(.center)
                            .monospacedDigit()
                            .font(.title2)
                            .foregroundColor(Color("textColor2"))
                        Spacer()
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("距离\(context.state.next20ResinCount)树脂")
                        .lineLimit(1)
                        .font(.caption)
                }
            } compactLeading: {
                Image("树脂").resizable().scaledToFit()
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.next20ResinRecoveryTime!, countsDown: true, showsHours: false)
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .foregroundColor(Color("textColor2"))
            } minimal: {
                VStack {
                    Image("树脂").resizable().scaledToFit()
                    Text(timerInterval: Date()...context.state.next20ResinRecoveryTime!, countsDown: true)
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                        .font(.caption2)
                }
            }
        }

    }
}

@available(iOS 16.1, *)
struct ResinRecoveryActivityWidgetLockScreenView: View {
    let context: ActivityViewContext<ResinRecoveryAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Image(systemName: "person.fill")
                Text(context.attributes.accountName)
            }
            .font(.footnote)
            .padding(.top, 3)
            .padding(.leading, 3)
            HStack {
                Spacer()
                Grid(verticalSpacing: 5) {
                    GridRow {
                        VStack(alignment: .trailing) {
                            Text("距离\(context.state.next20ResinCount)树脂")
                                .font(.caption2)
                            Text(timerInterval: Date()...context.state.next20ResinRecoveryTime!, countsDown: true)
                                .multilineTextAlignment(.trailing)
                                .font(.system(.title2, design: .rounded))
                        }
                        .gridColumnAlignment(.trailing)
                        .frame(width: 100)
                        Image("树脂")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 40)
                    }
                    GridRow {
                        VStack(alignment: .trailing) {
                            Text("距离160树脂")
                                .font(.caption2)
                            Text(timerInterval: Date()...context.state.resinFullTime, countsDown: true)
                                .multilineTextAlignment(.trailing)
                                .font(.system(.title2, design: .rounded))
                        }
                        .gridColumnAlignment(.trailing)
                        .frame(width: 100)
                        Image("浓缩树脂")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 40)
                    }
                }
                .shadow(radius: 0.8)
            }
        }
        .foregroundColor(Color("textColor3"))
        .padding()
        .background(alignment: .center) {
            WidgetBackgroundView(background: .randomNamecardBackground, darkModeOn: true)
        }
    }
}
