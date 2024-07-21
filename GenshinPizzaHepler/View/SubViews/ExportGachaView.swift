//
//  ExportGachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/4/3.
//

import SwiftUI
import UniformTypeIdentifiers

private typealias JsonFile = UIGFv4.Document

// MARK: - ExportGachaView

@available(iOS 15.0, *)
struct ExportGachaView: View {
    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: true
    )])
    var accounts: FetchedResults<AccountConfiguration>

    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    @Binding
    var isSheetShow: Bool

    @ObservedObject
    fileprivate var params: ExportGachaParams = .init()

    @State
    private var isExporterPresented: Bool = false

    @State
    private var uigfJson: UIGFv4?

    @State
    fileprivate var alert: AlertType? {
        didSet {
            if let alert = alert {
                switch alert {
                case .succeed:
                    isSucceedAlertShow = true
                case .failure:
                    isFailureAlertShow = true
                }
            } else {
                isSucceedAlertShow = false
                isFailureAlertShow = false
            }
        }
    }

    var defaultFileName: String {
        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        // 导出时间戳直接用 Date() 生成也无妨，误差在五秒钟之内。
        return "UIGFv4_GI_\(params.uid ?? "")_\(dateFormatter.string(from: Date()))"
    }

    fileprivate var file: JsonFile? {
        if let json = uigfJson {
            return .init(model: json)
        } else {
            return nil
        }
    }

    @ViewBuilder
    func main() -> some View {
        List {
            Section {
                Picker("app.gacha.account.select.title", selection: $params.uid) {
                    Group {
                        if params.uid == nil {
                            Text("app.gacha.account.select.notSelected").tag(String?(nil))
                        }
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
            }
            Section {
                Picker("gacha.export.chooseLanguage", selection: $params.lang) {
                    ForEach(GachaLanguageCode.allCases, id: \.rawValue) { code in
                        Text(code.localized).tag(code)
                    }
                }
                .disabled(true)
            } footer: {
                Text("gacha.uigf.notice.pendingMultilingualSupport")
            }
        }
    }

    var body: some View {
        NavigationStack {
            main()
                .navigationTitle("app.gacha.data.export.button")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("sys.cancel") {
                            isSheetShow.toggle()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("导出") {
                            exportButtonDidClick()
                        }
                        .disabled(params.uid == nil)
                    }
                }
                .alert(
                    "gacha.export.succeededInSavingToFile",
                    isPresented: $isSucceedAlertShow,
                    presenting: alert,
                    actions: { _ in
                        Button("button.okay") {
                            isSucceedAlertShow = false
                        }
                    },
                    message: { thisAlert in
                        switch thisAlert {
                        case let .succeed(url):
                            Text("gacha.export.fileSavedTo:\(url)")
                        default:
                            EmptyView()
                        }
                    }
                )
                .alert(
                    "gacha.export.failedInSavingToFile",
                    isPresented: $isFailureAlertShow,
                    presenting: alert,
                    actions: { _ in
                        Button("button.okay") {
                            isFailureAlertShow = false
                        }
                    },
                    message: { thisAlert in
                        switch thisAlert {
                        case let .failure(error):
                            Text("错误信息：\(error)")
                        default:
                            EmptyView()
                        }
                    }
                )
                .fileExporter(
                    isPresented: $isExporterPresented,
                    document: file,
                    contentType: .json,
                    defaultFilename: defaultFileName
                ) { result in
                    switch result {
                    case let .success(url):
                        alert = .succeed(url: url.absoluteString)
                    case let .failure(failure):
                        alert = .failure(message: failure.localizedDescription)
                    }
                }
        }
    }

    private func exportButtonDidClick() {
        let uid = params.uid!
        let items = gachaViewModel.manager.fetchAllMO(uid: uid).map { $0.toUIGFGachaItem(params.lang) }
        let newProfile: UIGFGachaProfile = .init(
            lang: .zhHans,
            list: items,
            timezone: GachaItem.getServerTimeZoneDelta(uid),
            uid: uid
        )
        uigfJson = .init(info: .init(), giProfiles: [newProfile])
        isExporterPresented.toggle()
    }

    @State
    private var isSucceedAlertShow: Bool = false
    @State
    private var isFailureAlertShow: Bool = false
}

// MARK: - ExportGachaParams

private class ExportGachaParams: ObservableObject {
    @Published
    var uid: String?
    @Published
    var lang: GachaLanguageCode = .zhHans
}

// MARK: - AlertType

private enum AlertType: Identifiable {
    case succeed(url: String)
    case failure(message: String)

    // MARK: Internal

    var id: String {
        switch self {
        case .succeed:
            return "succeed"
        case .failure:
            return "failure"
        }
    }
}
