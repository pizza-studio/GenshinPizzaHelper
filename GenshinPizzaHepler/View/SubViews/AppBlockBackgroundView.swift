//
//  AppBlockBackgroundView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//  提供主页帐号信息Block的背景

import Foundation
import SwiftUI
import WidgetKit

struct AppBlockBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    let background: WidgetBackground
    let darkModeOn: Bool

    var backgroundColors: [Color] { background.colors }
    var backgroundIconName: String? { background.iconName }
    var backgroundImageName: String? { background.imageName }

    @Binding var bgFadeOutAnimation: Bool


    var body: some View {
        ZStack{
            if !backgroundColors.isEmpty {
                LinearGradient(colors: backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            }

            if let backgroundIconName = backgroundIconName {
                GeometryReader { g in
                    Image(backgroundIconName)
                        .resizable()
                        .scaledToFill()
                        .opacity(0.05)
                        .padding()
                        .frame(width: g.size.width, height: g.size.height)
                }
            }

            if let backgroundImageName = backgroundImageName {
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .opacity(bgFadeOutAnimation ? 0 : 1)
                    .animation(.easeInOut(duration: 0.2), value: bgFadeOutAnimation)
                    .onChange(of: background) { new in
                        withAnimation {
                            self.bgFadeOutAnimation = false
                        }
                    }
            }

            if colorScheme == .dark && darkModeOn {
                Color.black
                    .opacity(0.3)
            }
        }
    }
}

