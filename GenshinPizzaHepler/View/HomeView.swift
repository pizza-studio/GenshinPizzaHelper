//
//  HomeView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: ViewModel
    var accounts: [Account] { viewModel.accounts }

    var animation: Namespace.ID
    @EnvironmentObject var detail: DisplayContentModel

    func getDate() -> String{
        let weekdays = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
        let weekdaysLocalized = weekdays.map { (item) -> String in
            let localizedStr = NSLocalizedString(item, comment: "week days")
            return String(format: localizedStr)
        }

        let calendar = Calendar.current
        let date = Date()
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let weekday = calendar.component(.weekday, from: date)

        let localizedString = NSLocalizedString("%lld月%lld日 %@", comment: "today")
        return String(format: localizedString, month, day, weekdaysLocalized[(weekday + 6) % 7])
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text(getDate())
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                            .padding(16)
                        Spacer()
                    }.frame(height: 16, alignment: .topLeading)
                    HStack {
                        Text("原神披萨小助手")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(16)
                        Spacer()
                        // Not used
                        Image("avator")
                            .resizable() // 画像のサイズを変更可能にする
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36, alignment: .center)
                            .clipShape(Circle()) // 正円形に切り抜く
                            .padding(.trailing, 16)
                    }

                    ForEach(viewModel.accounts, id: \.config.uuid) { account in
                        switch account.result {
                        case .success(let userData):
                            GameInfoBlock(userData: userData, accountName: account.config.name, accountUUIDString: account.config.uuid!.uuidString, animation: animation, widgetBackground: account.background)
                                .padding()
                                .cornerRadius(20)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .aspectRatio(170/364, contentMode: .fill)
                                .listRowBackground(Color.white.opacity(0))
                                .onTapGesture {
                                    if detail.animationDone {
                                        simpleTaptic(type: .light)
                                        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
                                            detail.userData = userData
                                            detail.accountName = account.config.name!
                                            detail.accountUUIDString = account.config.uuid!.uuidString
                                            detail.widgetBackground = account.background
                                            detail.viewConfig = WidgetViewConfiguration.defaultConfig
                                            detail.show = true
                                        }
                                    }
                                }
                                .contextMenu {
                                    Button("保存图片") {
                                        let view = GameInfoBlockForSave(userData: detail.userData, accountName: detail.accountName, accountUUIDString: detail.accountUUIDString, animation: animation, widgetBackground: detail.widgetBackground)
                                            .padding()
                                            .animation(.linear)
                                        let image = view.asUiImage()
                                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                    }
                                }
                        case .failure( _) :
                            HStack {
                                Spacer()
                                Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                                    .padding()
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .aspectRatio(170/364, contentMode: .fill)

                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}
