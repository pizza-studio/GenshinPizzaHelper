//
//  GachaSetting.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/31.
//

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

    @EnvironmentObject
    var viewModel: ViewModel
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
                Button("清理重复数据") {
                    alert = .duplicatedCleanCompleted(
                        gachaViewModel.manager
                            .cleanDuplicatedItems()
                    )
                }
            } footer: {
                Text("清理因iCloud同步导致出现的重复祈愿记录")
            }

            Section {
                Picker("选择帐号", selection: $account) {
                    Group {
                        Text("未选择").tag(String?(nil))
                        ForEach(
                            gachaViewModel.allAvaliableAccountUID,
                            id: \.self
                        ) { uid in
                            if let name = viewModel.accounts
                                .first(where: { $0.config.uid! == uid })?.config
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
                Toggle("删除所有时间的记录", isOn: $deleteAll)
                if !deleteAll {
                    DatePicker(
                        "开始日期",
                        selection: $startDate,
                        displayedComponents: .date
                    )
                    DatePicker(
                        "结束日期",
                        selection: $endDate,
                        displayedComponents: .date
                    )
                }
                Button("删除祈愿记录") {
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
                        "导出UIGF祈愿记录",
                        systemImage: "square.and.arrow.up.on.square"
                    )
                }
            }
//            #if DEBUG
//            Section {
//                Button("delete all records (DEBUG ONLY)") {
//                    gachaViewModel.manager.deleteAllRecord()
//                    gachaViewModel.refetchGachaItems()
//                }
//            }
//            #endif
        }
        .navigationTitle("祈愿数据管理")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isExportSheetShow, content: {
            ExportGachaView(isSheetShow: $isExportSheetShow)
        })
        .alert("确定要删除吗？", isPresented: $isDeleteConfirmAlertShow, presenting: alert, actions: { thisAlert in
            Button("删除", role: .destructive) {
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
        }, message: { thisAlert in
            let startDate: Date = deleteAll ? .distantPast : startDate
            let endDate: Date = deleteAll ? .distantFuture : endDate
            var rangeFormatter: DateIntervalFormatter {
                let formatter = DateIntervalFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                return formatter
            }
            let rangeDesc: String = deleteAll ? "所有".localized :
                rangeFormatter.string(from: startDate, to: endDate)
            Text(
                "即将删除「\(viewModel.accounts.first(where: { $0.config.uid! == account! })?.config.name ?? account!)」\(rangeDesc)的祈愿数据。"
            )
        })
        .alert("删除成功", isPresented: $isDeleteCompletedAlertShow, presenting: alert, actions: { thisAlert in
            Button("好") {
                alert = nil
            }
        }, message: { thisAlert in
            switch thisAlert {
            case let .deleteCompleted(count):
                Text("删除了\(count)条数据")
            default:
                EmptyView()
            }
        })
        .alert("清理重复数据成功", isPresented: $isDuplicatedCleanCompletedAlertShow, presenting: alert, actions: { thisAlert in
            Button("好") {
                alert = nil
            }
        }, message: { thisAlert in
            switch thisAlert {
            case let .duplicatedCleanCompleted(count):
                Text("删除了\(count)条重复数据")
            default:
                EmptyView()
            }
        })
    }

    // MARK: Fileprivate

    @State
    fileprivate var isDeleteConfirmAlertShow: Bool = false
    @State
    fileprivate var isDeleteCompletedAlertShow: Bool = false
    @State
    fileprivate var isDuplicatedCleanCompletedAlertShow: Bool = false
}
