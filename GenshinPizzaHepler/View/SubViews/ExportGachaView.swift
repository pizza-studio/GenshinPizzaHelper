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
    // MARK: Lifecycle

    public init(
        compactLayout: Bool = false,
        uid: String? = nil,
        dismissHandler newHandler: @escaping (() -> ()) = {}
    ) {
        self.compactLayout = compactLayout
        self.dismissHandler = newHandler
        params.uid = uid
    }

    // MARK: Internal

    @FetchRequest(sortDescriptors: [.init(
        keyPath: \Account.priority,
        ascending: true
    )])
    var accounts: FetchedResults<Account>

    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    let dismissHandler: () -> ()

    var defaultFileName: String {
        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        // 导出时间戳直接用 Date() 生成也无妨，误差在五秒钟之内。
        return "UIGFv4_GI_\(params.uid ?? "")_\(dateFormatter.string(from: Date()))"
    }

    var body: some View {
        Group {
            if compactLayout {
                compactMain()
            } else {
                NavigationStack {
                    main()
                        .navigationTitle("app.gacha.data.export.button")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("sys.cancel") {
                                    dismissHandler()
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("导出") {
                                    exportButtonDidClick()
                                }
                            }
                        }
                }
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
            message: { _ in
                messageView
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
            message: { _ in
                messageView
            }
        )
        .fileExporter(
            isPresented: $isExporterPresented,
            document: file,
            contentType: .json,
            defaultFilename: defaultFileName
        ) { result in
            handleFileExportResult(for: result)
        }
    }

    @ViewBuilder
    func main() -> some View {
        List {
            Section {
                accountPicker()
            }
            Section {
                Picker("gacha.export.chooseLanguage", selection: $params.lang) {
                    ForEach(GachaLanguageCode.allCases, id: \.rawValue) { code in
                        Text(code.localized).tag(code)
                    }
                }
            } footer: {
                Text("app.gacha.explainUIGF")
                    + Text(verbatim: "\n\n")
                    + Text("app.gacha.uigf.affLink.[UIGF](https://uigf.org/)")
            }
        }
    }

    @ViewBuilder
    func compactMain() -> some View {
        Menu {
            Menu {
                ForEach(GachaLanguageCode.allCases, id: \.rawValue) { code in
                    Button(code.localized) {
                        params.lang = code
                        exportButtonDidClick()
                    }
                }
            } label: {
                Text(verbatim: "UIGFv4.0")
            }
        } label: {
            Label("gacha.manage.uigf.export.toolbarTitle", systemSymbol: .squareAndArrowUpOnSquare)
        }
    }

    // MARK: Fileprivate

    @ObservedObject
    fileprivate var params: ExportGachaParams = .init()

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

    fileprivate var file: JsonFile? {
        if let json = uigfJson {
            return .init(model: json)
        } else {
            return nil
        }
    }

    // MARK: Private

    @State
    private var isExporterPresented: Bool = false

    @State
    private var uigfJson: UIGFv4?

    private let compactLayout: Bool

    @State
    private var isSucceedAlertShow: Bool = false
    @State
    private var isFailureAlertShow: Bool = false

    private var accountPickerPairs: [(value: String, tag: String?)] {
        var result = [(value: String, tag: String?)]()
        if params.uid == nil {
            let i18nKey = "app.gacha.account.select.selectAll"
            let i18nStr = String(localized: .init(stringLiteral: i18nKey))
            result.append((i18nStr, nil))
        }
        result.append(contentsOf: gachaViewModel.allAvaliableAccountUID.map { uid in
            if let name = firstAccount(uid: uid)?.name {
                return (value: "\(name) (\(uid))", tag: uid)
            } else {
                return (value: "UID: \(uid)", tag: uid)
            }
        })
        return result
    }

    @ViewBuilder
    private var messageView: some View {
        switch alert {
        case let .failure(error):
            Text("错误信息：\(error)")
        case let .succeed(url):
            Text("gacha.export.fileSavedTo:\(url)")
        default:
            EmptyView()
        }
    }

    private func firstAccount(uid: String) -> Account? {
        accounts.first(where: { $0.uid == uid })
    }

    @ViewBuilder
    private func accountPicker() -> some View {
        Picker("app.gacha.account.select.title", selection: $params.uid) {
            Group {
                ForEach(accountPickerPairs, id: \.tag) { value, tag in
                    Text(value).tag(tag)
                }
            }
        }
    }

    @MainActor
    private func handleFileExportResult(for result: Result<URL, any Error>) {
        switch result {
        case let .success(url):
            alert = .succeed(url: url.absoluteString)
        case let .failure(failure):
            alert = .failure(message: failure.localizedDescription)
        }
    }

    private func exportButtonDidClick() {
        var profiles = [UIGFGachaProfile]()
        var uids = [String]()
        if let uid = params.uid {
            uids.append(uid)
        } else {
            uids.append(contentsOf: accounts.compactMap(\.uid))
        }
        uids.forEach { uid in
            let items = gachaViewModel.manager.fetchAllMO(uid: uid).map {
                $0.toUIGFGachaItem(params.lang)
            }
            // items.updateLanguage(params.lang) 这句或许用不到了。
            let newProfile: UIGFGachaProfile = .init(
                lang: params.lang,
                list: items,
                timezone: GachaItem.getServerTimeZoneDelta(uid),
                uid: uid
            )
            profiles.append(newProfile)
        }
        uigfJson = .init(info: .init(), giProfiles: profiles)
        isExporterPresented.toggle()
    }
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
