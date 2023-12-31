//
//  ManageAccountsView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import AlertToast
import SwiftUI

// MARK: - AlertToastVariable

class AlertToastVariable: ObservableObject {
    @Published
    var isDoneButtonTapped: Bool = false
    @Published
    var isLoginSucceeded: Bool = false
}

// MARK: - ManageAccountsView

struct ManageAccountsView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                Button {
                    sheetType = .createNewAccount(AccountConfiguration(context: viewContext))
                } label: {
                    Label("settings.account.addAccount", systemSymbol: .plusCircle)
                }
            }
            Section {
                ForEach(accounts) { account in
                    Button {
                        sheetType = .editExistedAccount(account)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(account.name ?? "")
                                    .foregroundColor(.primary)
                                HStack {
                                    Text(account.uid ?? "")
                                    Text(account.server.localized)
                                }
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemSymbol: .sliderHorizontal3)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
        }
        .navigationTitle("settings.account.manage.title")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $sheetType, content: { type in
            switch type {
            case let .createNewAccount(newAccount):
                CreateAccountSheetView(account: newAccount, isShown: isShown)
            case let .editExistedAccount(account):
                EditAccountSheetView(account: account, isShown: isShown)
            }
        })
        .onAppear {
            accounts.forEach { account in
                if !account.isValid() {
                    viewContext.delete(account)
                    try? viewContext.save()
                }
            }
        }
        .toolbar {
            EditButton()
        }
        .toast(isPresenting: $alertToastVariable.isDoneButtonTapped) {
            AlertToast(
                displayMode: .alert,
                type: .complete(.green),
                title: "account.added.success"
            )
        }
        .environmentObject(alertToastVariable)
    }

    var isShown: Binding<Bool> {
        .init {
            sheetType != nil
        } set: { newValue in
            if !newValue { sheetType = nil }
        }
    }

    // MARK: Private

    private enum SheetType: Identifiable {
        case createNewAccount(AccountConfiguration)
        case editExistedAccount(AccountConfiguration)

        // MARK: Internal

        var id: UUID {
            switch self {
            case let .createNewAccount(account):
                return account.uuid ?? UUID()
            case let .editExistedAccount(account):
                return account.uuid ?? UUID()
            }
        }
    }

    @StateObject
    private var alertToastVariable = AlertToastVariable()

    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \AccountConfiguration.priority, ascending: true),
        ],
        animation: .default
    )
    private var accounts: FetchedResults<AccountConfiguration>

    @State
    private var sheetType: SheetType?

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { accounts[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        withAnimation {
            var revisedAccounts: [AccountConfiguration] = accounts.map { $0 }
            revisedAccounts.move(fromOffsets: source, toOffset: destination)

            for (index, account) in revisedAccounts.enumerated() {
                account.priority = index
            }

            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
}
