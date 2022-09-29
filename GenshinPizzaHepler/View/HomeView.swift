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
                            .padding(.bottom)

                        // MARK: - 当前活动
                        CurrentEventNavigator(eventContents: $eventContents)
                            .padding(.bottom)

                        // MARK: - 账号信息
                        accountInfoCards()
                    }
                }
            }
            .navigationTitle("原神披萨小助手")
            .navigationBarTitleDisplayMode(.large)
            
        }
        .navigationViewStyle(.stack)
        .myRefreshable {
            withAnimation {
                viewModel.refreshData()
                getCurrentEvent()
            }
        }
    }

    func getCurrentEvent() -> Void {
        DispatchQueue.global().async {
            API.OpenAPIs.fetchCurrentEvents { result in
                switch result {
                case .success(let events):
                    withAnimation {
                        self.eventContents = [EventModel](events.event.values)
                        self.eventContents = eventContents.sorted {
                            $0.endAt < $1.endAt
                        }
                    }
                case .failure(_):
                    break
                }
            }
        }
    }

    @ViewBuilder
    func accountInfoCards() -> some View {
        ForEach($viewModel.accounts, id: \.config.uuid) { $account in
            if account.fetchComplete {
                switch account.result! {
                case .success(let userData):
                    let gameInfoBlock: some View = GameInfoBlock(userData: userData, accountName: account.config.name, accountUUIDString: account.config.uuid!.uuidString, animation: animation, widgetBackground: account.background, bgFadeOutAnimation: $bgFadeOutAnimation)
                        .padding([.bottom, .horizontal])
                        .listRowBackground(Color.white.opacity(0))
                        .onTapGesture {
                            simpleTaptic(type: .medium)
                            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
                                viewModel.showDetailOfAccount = account
                            }
                        }
                    if #available (iOS 16, *) {
                        if account != viewModel.showDetailOfAccount {
                            gameInfoBlock
                                .contextMenu {
                                    Button("保存图片".localized) {
                                        let view = GameInfoBlockForSave(userData: userData, accountName: account.config.name ?? "", accountUUIDString: account.config.uuid?.uuidString ?? "", animation: animation, widgetBackground: account.background)
                                        let renderer = ImageRenderer(content: view)
                                        renderer.scale = UIScreen.main.scale
                                        if let image = renderer.uiImage {
                                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                        }
                                    }
                                }
                        }
                    } else {
                        gameInfoBlock
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
                            .padding([.bottom, .horizontal])
                        }
                    }
                }
            } else {
                ProgressView()
                    .padding([.bottom, .horizontal])
            }

        }
    }



}


extension View {
    @ViewBuilder
    func myRefreshable(action: @escaping () -> Void) -> some View {
        if #available(iOS 15, *) {
            self.refreshable {
                action()
            }
        } else {
            self
        }
    }
}
