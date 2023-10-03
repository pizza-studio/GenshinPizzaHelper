//
//  AccountManagementView.swift
//  GenshinPizzaHepler
//
//  Created by ShikiSuen on 2023/10/2.
//

import AlertToast
import SwiftUI

// MARK: - AccountManagementView

struct AccountManagementView: View {
    @EnvironmentObject
    var viewModel: ViewModel

    @State
    var editMode: EditMode = .inactive

    var accounts: [Account] { viewModel.accounts }

    var body: some View {
        Group {
            mainView()
                .navigationViewStyle(.stack)
        }
        .navigationBarTitle("我的账号", displayMode: .inline)
    }

    @ViewBuilder
    func mainView() -> some View {
        List {
            Section {
                ForEach(
                    $viewModel.accounts,
                    id: \.config.uuid
                ) { $account in
                    NavigationLink(
                        destination: AccountDetailView(account: $account)
                    ) {
                        AccountInfoView(account: account)
                    }
                }
                .onDelete { indexSet in
                    indexSet
                        .forEach {
                            viewModel.deleteAccount(account: accounts[$0])
                        }
                }
                NavigationLink(destination: AddAccountView()) {
                    Label("添加账号", systemImage: "plus.circle")
                }
            } header: {
                HStack {
                    Text("我的账号")
                    Spacer()
                    EditModeButton(editMode: $editMode)
                }
            }
        }.environment(\.editMode, $editMode)
    }
}

// MARK: - EditModeButton

private struct EditModeButton: View {
    @Binding
    var editMode: EditMode

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.1)) {
                if editMode.isEditing {
                    editMode = .inactive
                } else {
                    editMode = .active
                }
            }
        } label: {
            if editMode.isEditing {
                Text("完成")
                    .font(.footnote)
            } else {
                Text("编辑")
                    .font(.footnote)
            }
        }
    }
}
