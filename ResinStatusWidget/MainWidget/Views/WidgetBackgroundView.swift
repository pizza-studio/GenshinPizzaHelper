//
//  WidgetBackgroundView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//  Widget背景提供

import SwiftUI
import WidgetKit

struct WidgetBackgroundView: View {
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    @Environment(\.widgetFamily)
    var widgetFamily: WidgetFamily
    let background: WidgetBackground
    let darkModeOn: Bool

    @State
    var proxy: GeometryProxy?

    var backgroundColors: [Color] { background.colors }
    var backgroundIconName: String? { background.iconName }
    var backgroundImageName: String? { background.imageName }
    var body: some View {
        ZStack {
            if !backgroundColors.isEmpty {
                LinearGradient(
                    colors: backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            if let backgroundIconName = backgroundIconName {
                GeometryReader { g in
                    Image(backgroundIconName)
                        .resizable()
                        .scaledToFill()
                        .opacity(0.05)
                        .padding()
                        .frame(width: g.size.width, height: g.size.height)
                        .onAppear {
                            proxy = g
                        }
                }
            }

            if let backgroundImage = UIImage(named: backgroundImageName ?? "") {
                switch widgetFamily {
                case .systemLarge, .systemSmall:
                    GeometryReader { g in
                        Image(uiImage: backgroundImage)
                            .resizable()
                            .scaledToFill()
                            .offset(x: -g.size.width)
                    }
                    .onAppear {
                        NSLog(
                            "[OPHelper] Successfully initialized UIImage: " +
                                (backgroundImageName ?? "File name nulled.")
                        )
                    }
                default:
                    // 包括 .systemMedium
                    Image(uiImage: backgroundImage)
                        .resizable()
                        .scaledToFill()
                        .onAppear {
                            NSLog(
                                "[OPHelper] Successfully initialized UIImage: " +
                                    (backgroundImageName ?? "File name nulled.")
                            )
                        }
                }
            } else {
                EmptyView().onAppear {
                    NSLog(
                        "[OPHelper] Failed from initializing UIImage: " +
                            (backgroundImageName ?? "File name nulled.")
                    )
                }
            }

            if colorScheme == .dark, darkModeOn {
                Color.black
                    .opacity(0.3)
            }
        }
    }
}
