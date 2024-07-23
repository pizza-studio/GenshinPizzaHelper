//
//  GachaSetting.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/31.
//

import SFSafeSymbols
import SwiftUI

@available(iOS 15.0, *)
struct GachaSetting: View {
    // MARK: Internal

    enum AlertType: Identifiable {
        case deleteCheck
        case deleteCompleted(Int)
        case duplicatedCleanCompleted(Int)

        // MARK: Internal

        var id: String {
            switch self {
            case .deleteCheck:
                return "deleteCheck"
            case let .deleteCompleted(count):
                return "deleteCompleted: \(count)"
            case let .duplicatedCleanCompleted(count):
                return "duplicatedCleanCompleted: \(count)"
            }
        }
    }

    @FetchRequest(sortDescriptors: [.init(
        keyPath: \Account.priority,
        ascending: true
    )])
    var accounts: FetchedResults<Account>

    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    @State
    var account: String?

    @State
    var startDate: Date = Calendar.current.date(
        byAdding: DateComponents(month: -6),
        to: Date()
    )!
    @State
    var endDate: Date = .init()
    @State
    var deleteAll: Bool = false

    @State
    var alert: AlertType? {
        didSet {
            if let alert = alert {
                switch alert {
                case .deleteCheck:
                    isDeleteConfirmAlertShow = true
                case .deleteCompleted:
                    isDeleteCompletedAlertShow = true
                case .duplicatedCleanCompleted:
                    isDuplicatedCleanCompletedAlertShow = true
                }
            } else {
                isDeleteConfirmAlertShow = false
                isDeleteCompletedAlertShow = false
                isDuplicatedCleanCompletedAlertShow = false
            }
        }
    }

    @State
    var isExportSheetShow: Bool = false

    var body: some View {
        List {
            Section {
                Button("app.gacha.data.clean.title") {
                    alert = .duplicatedCleanCompleted(
                        gachaViewModel.manager
                            .cleanDuplicatedItems()
                    )
                }
            } footer: {
                Text("app.gacha.data.clean.detail")
            }

            Section {
                Picker("app.gacha.account.select.title", selection: $account) {
                    Group {
                        Text("app.gacha.account.select.notSelected").tag(String?(nil))
                        ForEach(
                            gachaViewModel.allAvaliableAccountUID,
                            id: \.self
                        ) { uid in
                            if let name = accounts
                                .first(where: { $0.uid! == uid })?
                                .name {
                                Text("\(name) (\(uid))")
                                    .tag(Optional(uid))
                            } else {
                                Text("\(uid)")
                                    .tag(Optional(uid))
                            }
                        }
                    }
                }
                Toggle("app.gacha.data.clean.all", isOn: $deleteAll)
                if !deleteAll {
                    DatePicker(
                        "app.gacha.data.clean.date.start",
                        selection: $startDate,
                        displayedComponents: .date
                    )
                    DatePicker(
                        "app.gacha.data.clean.date.end",
                        selection: $endDate,
                        displayedComponents: .date
                    )
                }
                Button("app.gacha.data.clean.button") {
                    alert = .deleteCheck
                }
                .disabled(account == nil)
            }

            Section {
                Button {
                    withAnimation {
                        isExportSheetShow.toggle()
                    }
                } label: {
                    Label(
                        "app.gacha.export.title",
                        systemSymbol: .squareAndArrowUpOnSquare
                    )
                }
            }
            if isDebugButtonsShow {
                Section {
                    let buttonTextForRemovingAllRecords = "Delete all records (DEBUG ONLY)"
                    Button(buttonTextForRemovingAllRecords) {
                        gachaViewModel.manager.deleteAllRecord()
                        gachaViewModel.refetchGachaItems()
                    }
                }
            }
        }
        .navigationTitle("app.gacha.data.management.title")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isExportSheetShow, content: {
            ExportGachaView {
                isExportSheetShow.toggle()
            }
        })
        .alert(
            "gacha.prompt.dataRemoval".localized,
            isPresented: $isDeleteConfirmAlertShow,
            presenting: alert,
            actions: deleteConfirmAlertButton,
            message: deleteConfirmAlertMessage
        )
        .alert(
            "gacha.notice.succeededInRemovingData".localized,
            isPresented: $isDeleteCompletedAlertShow,
            presenting: alert,
            actions: defaultDismissButton,
            message: deleteCompletedAlertMessage
        )
        .alert(
            "gacha.notice.succeededInDeduplicatingData".localized,
            isPresented: $isDuplicatedCleanCompletedAlertShow,
            presenting: alert,
            actions: defaultDismissButton,
            message: duplicatedCleanCompletedAlertMessage
        )
        .onTapGesture(count: 5) {
            withAnimation {
                isDebugButtonsShow.toggle()
            }
        }
    }

    @ViewBuilder
    func defaultDismissButton(_ thisAlert: AlertType) -> some View {
        Button("button.okay") {
            alert = nil
        }
    }

    @ViewBuilder
    func duplicatedCleanCompletedAlertMessage(_ thisAlert: AlertType) -> some View {
        switch thisAlert {
        case let .duplicatedCleanCompleted(count):
            let deleteContent = String(
                format: "app.gacha.data.clean.complete.info.duplicated:%lld".localized, count
            )
            Text(deleteContent)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    func deleteCompletedAlertMessage(_ thisAlert: AlertType) -> some View {
        switch thisAlert {
        case let .deleteCompleted(count):
            let deleteContent = String(format: "app.gacha.data.clean.complete.info:%lld".localized, count)
            Text(deleteContent)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    func deleteConfirmAlertButton(_ thisAlert: AlertType) -> some View {
        Button("gacha.term.delete", role: .destructive) {
            alert = nil
            alert = .deleteCompleted(
                gachaViewModel.manager
                    .deleteData(
                        for: account!,
                        startDate: startDate,
                        endData: endDate
                    )
            )
            withAnimation {
                account = nil
            }
        }
    }

    @ViewBuilder
    func deleteConfirmAlertMessage(_ thisAlert: AlertType) -> some View {
        let startDate: Date = deleteAll ? .distantPast : startDate
        let endDate: Date = deleteAll ? .distantFuture : endDate
        let rangeDesc: String = deleteAll ? "sys.all".localized :
            Self.rangeFormatter.string(from: startDate, to: endDate)
        let nameDesc: String = accounts.first(where: { $0.uid! == account! })?
            .name ?? account ?? ""
        let messageContent = String(format: "app.gacha.data.clean.confirm:%@%@".localized, nameDesc, rangeDesc)
        Text(messageContent)
    }

    // MARK: Private

    @State
    private var isDeleteConfirmAlertShow: Bool = false
    @State
    private var isDeleteCompletedAlertShow: Bool = false
    @State
    private var isDuplicatedCleanCompletedAlertShow: Bool = false
    @State
    private var isDebugButtonsShow = false

    private static let rangeFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}
