//
//  ToolsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/17.
//

import SwiftUI

@available(iOS 15.0, *)
struct ToolsView: View {
    @EnvironmentObject var viewModel: ViewModel
    var accounts: [Account] { viewModel.accounts }
    @State var selectedAccount = 0

    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack {
                        HStack {
                            Text("我的角色")
                                .font(.footnote)
                            Spacer()
                        }
                        Divider()
                    }
                    .listRowSeparator(.hidden)
                    ScrollView(.horizontal) {
                        HStack {
                            Image(systemName: "safari")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Image(systemName: "safari")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Image(systemName: "safari")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        .padding()
                    }
                    .padding(.bottom, 10)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }

                Section {
                    HStack(spacing: 30) {
                        VStack {
                            VStack {
                                HStack {
                                    Text("深境螺旋")
                                        .font(.footnote)
                                    Spacer()
                                }
                                .padding(.top, 5)
                                Divider()
                            }
                            Text("12-3")
                                .font(.largeTitle)
                                .frame(height: 120)
                                .padding(.bottom, 10)
                        }
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)))
                        VStack {
                            VStack {
                                HStack {
                                    Text("深境螺旋")
                                        .font(.footnote)
                                    Spacer()
                                }
                                .padding(.top, 5)
                                Divider()
                            }
                            Text("12-3")
                                .font(.largeTitle)
                                .frame(height: 120)
                                .padding(.bottom, 10)
                        }
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)))
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color(UIColor.secondarySystemBackground))
                
                Section {
                    VStack {
                        HStack {
                            Text("第三方工具")
                                .font(.footnote)
                            Spacer()
                        }
                    }
                    Text("原神中日英词典")
                    Text("原神计算器")
                }

            }
            .navigationTitle("原神小工具")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Menu {
                    Picker("选择帐号", selection: $selectedAccount) {
                        ForEach(accounts, id:\.config.id) { account in
                            Text(account.config.name ?? "Account Name Error")
                                .tag(getAccountItemIndex(item: account))
                        }
                    }
                } label: {
                    Label("选择帐号", systemImage: "arrow.left.arrow.right.circle")
                }
            }
            .onChange(of: selectedAccount) { _ in
                print(accounts[selectedAccount].config.name)
            }
        }
    }

    func getAccountItemIndex(item: Account) -> Int {
        return accounts.firstIndex { currentItem in
            return currentItem.config.id == item.config.id
        } ?? 0
    }
}
