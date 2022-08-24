//
//  EachExpeditionView.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/23.
//

import SwiftUI

struct EachExpeditionView: View {
    let expedition: Expedition
    let viewConfig: WidgetViewConfiguration = .defaultConfig

    var body: some View {
        HStack {
            webView(url: expedition.avatarSideIconUrl)
            VStack(alignment: .leading) {
                Text(expedition.recoveryTime.describeIntervalLong ?? "已完成")
                    .lineLimit(1)
                    .font(.footnote)
                    .minimumScaleFactor(0.4)
                percentageBar(expedition.percentage)
                    .environment(\.colorScheme, .light)
            }


        }
        .foregroundColor(Color("textColor3"))
//        .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
//        .background(WidgetBackgroundView(background: .randomNamecardBackground, darkModeOn: true))




    }

    @ViewBuilder
    func webView(url: URL) -> some View {
        GeometryReader { g in
            NetworkImage(url: expedition.avatarSideIconUrl)
                .scaleEffect(1.2)
                .scaledToFit()
                .offset(x: -g.size.width * 0.05, y: -g.size.height * 0.17)
//                .border(.blue, width: 3)
        }
        .frame(maxWidth: 50, maxHeight: 50)
    }

    @ViewBuilder
    func percentageBar(_ percentage: Double) -> some View {
        let cornerRadius: CGFloat = 3
        if #available(iOS 15.0, iOSApplicationExtension 15.0, *) {
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .frame(width: g.size.width, height: g.size.height)
                        .foregroundStyle(.ultraThinMaterial)
                        .opacity(0.6)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .frame(width: g.size.width * percentage, height: g.size.height)
                        .foregroundStyle(.thickMaterial)
                }
                .aspectRatio(30/1, contentMode: .fit)
//                .preferredColorScheme(.light)
            }
            .frame(height: 7)
        } else {
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .opacity(0.3)
                        .frame(width: g.size.width, height: g.size.height)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .frame(width: g.size.width * percentage, height: g.size.height)
                }
                .aspectRatio(30/1, contentMode: .fit)
            }
            .frame(height: 7)
        }



    }
}

struct NetworkImage: View {

  let url: URL?

  var body: some View {

    Group {
     if let url = url, let imageData = try? Data(contentsOf: url),
       let uiImage = UIImage(data: imageData) {

       Image(uiImage: uiImage)
         .resizable()
//         .aspectRatio(contentMode: .fill)
      }
      else {
       Image("placeholder-image")
      }
    }
  }

}


