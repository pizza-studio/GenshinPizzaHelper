//
//  LockScreenHomeCoinWidgetRectangular.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/11/27.
//

import HoYoKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenHomeCoinWidgetRectangular

@available(iOSApplicationExtension 16.0, *)
struct LockScreenHomeCoinWidgetRectangular: View {
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode

    let result: Result<any DailyNote, any Error>

    var body: some View {
        switch widgetRenderingMode {
        case .fullColor:
            switch result {
            case let .success(data):
                Grid(alignment: .leading) {
                    GridRow {
                        let size: CGFloat = 10
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            let iconSize: CGFloat = size * 4 / 5
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: iconSize))
                                .offset(x: -2)
                            Text(
                                "LockScreenHomeCoinWidgetRectangular.resin"
                                    .localized
                            )
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        }
                        .foregroundColor(Color("iconColor.resin"))
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let iconSize: CGFloat = size * 8 / 9
                            Text("\(Image("icon.homeCoin"))")
                                .font(.system(size: iconSize))
                            Text(
                                "LockScreenHomeCoinWidgetRectangular.homeCoin"
                                    .localized
                            )
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        }
                        .foregroundColor(Color("iconColor.homeCoin"))
                        Spacer()
                    }
                    GridRow(alignment: .lastTextBaseline) {
                        let size: CGFloat = 23
                        Text("\(data.resinInformation.calculatedCurrentResin)")
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        Spacer()
                        Text("\(data.homeCoinInformation.calculatedCurrentHomeCoin)")
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        Spacer()
                    }
                    .fixedSize()
                    .foregroundColor(.primary)
                    .widgetAccentable()
                    GridRow(alignment: .lastTextBaseline) {
                        if data.resinInformation.calculatedCurrentResin >= data.resinInformation.maxResin {
                            Text("已回满")
                        } else {
                            Text(
                                "\(dateFormatter.string(from: data.resinInformation.resinRecoveryTime))"
                            )
                        }
                        Spacer()
                        if data.homeCoinInformation.calculatedCurrentHomeCoin >= data.homeCoinInformation.maxHomeCoin {
                            Text("已回满")
                        } else {
                            Text(
                                "\(dateFormatter.string(from: data.homeCoinInformation.fullTime))"
                            )
                        }
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            case .failure:
                Grid(alignment: .leading) {
                    GridRow(alignment: .lastTextBaseline) {
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            let size: CGFloat = 20
                            let iconSize: CGFloat = size * 4 / 5
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: iconSize))
                                .offset(x: -2)
                            Text("…")
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                        }
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 20
                            let iconSize: CGFloat = size * 8 / 9
                            Text("\(Image("icon.homeCoin"))")
                                .font(.system(size: iconSize))
                            Text("…")
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                        }
                    }
                    .fixedSize()
                    .foregroundColor(.primary)
                    .widgetAccentable()
                    GridRow(alignment: .lastTextBaseline) {
                        Text("…")
                        Text("…")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
        default:
            switch result {
            case let .success(data):
                Grid(alignment: .leading) {
                    GridRow {
                        let size: CGFloat = 10
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            let iconSize: CGFloat = size * 4 / 5
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: iconSize))
                                .offset(x: -2)
                            Text(
                                "LockScreenHomeCoinWidgetRectangular.resin"
                                    .localized
                            )
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        }
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let iconSize: CGFloat = size * 8 / 9
                            Text("\(Image("icon.homeCoin"))")
                                .font(.system(size: iconSize))
                            Text(
                                "LockScreenHomeCoinWidgetRectangular.homeCoin"
                                    .localized
                            )
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        }
                        Spacer()
                    }
                    GridRow(alignment: .lastTextBaseline) {
                        let size: CGFloat = 23
                        Text("\(data.resinInformation.calculatedCurrentResin)")
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        Spacer()
                        Text("\(data.homeCoinInformation.calculatedCurrentHomeCoin)")
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        Spacer()
                    }
                    .fixedSize()
                    .foregroundColor(.primary)
                    .widgetAccentable()
                    GridRow(alignment: .lastTextBaseline) {
                        if data.resinInformation.calculatedCurrentResin >= data.resinInformation.maxResin {
                            Text("已回满")
                        } else {
                            Text(
                                "\(dateFormatter.string(from: data.resinInformation.resinRecoveryTime))"
                            )
                        }
                        Spacer()
                        if data.homeCoinInformation.calculatedCurrentHomeCoin >= data.homeCoinInformation.maxHomeCoin {
                            Text("已回满")
                        } else {
                            Text(
                                "\(dateFormatter.string(from: data.homeCoinInformation.fullTime))"
                            )
                        }
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            case .failure:
                Grid(alignment: .leading) {
                    GridRow {
                        let size: CGFloat = 10
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            let iconSize: CGFloat = size * 4 / 5
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: iconSize))
                                .offset(x: -2)
                            Text(
                                "LockScreenHomeCoinWidgetRectangular.resin"
                                    .localized
                            )
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        }
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let iconSize: CGFloat = size * 8 / 9
                            Text("\(Image("icon.homeCoin"))")
                                .font(.system(size: iconSize))
                            Text(
                                "LockScreenHomeCoinWidgetRectangular.homeCoin"
                                    .localized
                            )
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        }
                        Spacer()
                    }
                    GridRow(alignment: .lastTextBaseline) {
                        let size: CGFloat = 23
                        Text("…")
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        Spacer()
                        Text("…")
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        Spacer()
                    }
                    .fixedSize()
                    .foregroundColor(.primary)
                    .widgetAccentable()
                    GridRow(alignment: .lastTextBaseline) {
                        Text("…")
                        Spacer()
                        Text("…")
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .none
    fmt.timeStyle = .short
    return fmt
}()

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
