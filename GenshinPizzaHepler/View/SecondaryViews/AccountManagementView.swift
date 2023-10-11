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
        .navigationBarTitle("settings.account.myAccount", displayMode: .inline)
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
                    Label("settings.account.addAccount", systemImage: "plus.circle")
                }
            } header: {
                HStack {
                    Text("settings.account.myAccount")
                    Spacer()
                    EditModeButton(editMode: $editMode)
                }
            }
        }
        .frame(maxWidth: 550)
        .sectionSpacing(UIFont.systemFontSize)
        .environment(\.editMode, $editMode)
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
