//
//  HomeView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//  展示所有帐号的主页

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: ViewModel
    var accounts: [Account] { viewModel.accounts }
    @State var eventContents: [EventModel] = []

    var animation: Namespace.ID
    @EnvironmentObject var detail: DisplayContentModel

    @Binding var bgFadeOutAnimation: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if viewModel.accounts.isEmpty {
                        NavigationLink(destination: AddAccountView()) {
                            Label("请先添加帐号", systemImage: "plus.circle")
                        }
                        .padding()
                        .blurMaterialBackground()
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .padding(.top, 30)
                    } else {
                        // MARK: - 今日材料
                        InAppMaterialNavigator()
                            .onAppear(perform: getCurrentEvent)

                        // MARK: - 当前活动
                        CurrentEventNavigator(eventContents: $eventContents)

                        // MARK: - 帐号基本信息
                        HStack {
                            Text("帐号基本信息")
                                .font(.caption)
                            Spacer()
                        }
                        .padding(.top)
                        .padding(.bottom, -10)
                        .padding(.horizontal, 30)

                        ForEach($viewModel.accounts, id: \.config.uuid) { $account in
                            if account.fetchComplete {
                                switch account.result {
                                case .success(let userData):
                                    if #available (iOS 16, *) {
                                        GameInfoBlock(userData: userData, accountName: account.config.name, accountUUIDString: account.config.uuid!.uuidString, animation: animation, widgetBackground: account.background, bgFadeOutAnimation: $bgFadeOutAnimation)
                                            .padding()
                                            .listRowBackground(Color.white.opacity(0))
                                            .onTapGesture {
    //                                            UserNotificationCenter.shared.createAllNotification(for: account.config.name!, with: userData, uid: account.config.uid!)
    //                                            UserNotificationCenter.shared.printAllNotificationRequest()
    //                                            UserNotificationCenter.shared.testNotification()
                                                simpleTaptic(type: .medium)
                                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
                                                    detail.userData = userData
                                                    detail.accountName = account.config.name!
                                                    detail.accountUUIDString = account.config.uuid!.uuidString
                                                    detail.widgetBackground = account.background
                                                    detail.viewConfig = WidgetViewConfiguration.defaultConfig
                                                    detail.accountData = account.config
                                                    detail.show = true
                                                }
                                            }
                                            .contextMenu {
                                                Button("保存图片".localized) {
                                                    let view = GameInfoBlockForSave(userData: detail.userData, accountName: account.config.name ?? "", accountUUIDString: detail.accountUUIDString, animation: animation, widgetBackground: account.background)
                                                    let renderer = ImageRenderer(content: view)
                                                    renderer.scale = UIScreen.main.scale
                                                    if let image = renderer.uiImage {
                                                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                                    }
                                                }
                                            }
                                    } else {
                                        GameInfoBlock(userData: userData, accountName: account.config.name, accountUUIDString: account.config.uuid!.uuidString, animation: animation, widgetBackground: account.background, bgFadeOutAnimation: $bgFadeOutAnimation)
                                            .padding()
                                            .listRowBackground(Color.white.opacity(0))
                                            .onTapGesture {
                                                simpleTaptic(type: .medium)
                                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
                                                    detail.userData = userData
                                                    detail.accountName = account.config.name!
                                                    detail.accountUUIDString = account.config.uuid!.uuidString
                                                    detail.widgetBackground = account.background
                                                    detail.viewConfig = WidgetViewConfiguration.defaultConfig
                                                    detail.accountData = account.config
                                                    detail.show = true
                                                }
                                            }
                                    }

                                case .failure( _) :
                                    HStack {
                                        NavigationLink {
                                            AccountDetailView(account: $account)
                                        } label: {
                                            ZStack {
                                                Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                                                    .padding()
                                                    .foregroundColor(.red)
                                                HStack {
                                                    Spacer()
                                                    Text(account.config.name!)
                                                        .foregroundColor(Color(UIColor.systemGray4))
                                                        .font(.caption2)
                                                        .padding(.horizontal)
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                            } else {
                                ProgressView()
                                    .padding()
                            }

                        }
                    }
                }
            }
            .navigationTitle("原神披萨小助手")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
    }

    func getCurrentEvent() -> Void {
        if self.eventContents.isEmpty {
            DispatchQueue.global().async {
                API.OpenAPIs.fetchCurrentEvents { result in
                    switch result {
                    case .success(let events):
                        self.eventContents = [EventModel](events.event.values)
                        self.eventContents = eventContents.sorted {
                            $0.endAt < $1.endAt
                        }
                    case .failure(_):
                        break
                    }
                }
            }
        }
    }
}
