//
//  ImportGachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/4/2.
//

import AlertToast
import CoreXLSX
import Defaults
import GIPizzaKit
import SFSafeSymbols
import SwiftUI
import UniformTypeIdentifiers

// MARK: - ImportGachaView

@available(iOS 15.0, *)
struct ImportGachaView: View {
    // MARK: Internal

    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    @State
    var isHelpSheetShow: Bool = false

    @State
    var isCompleteAlertShow: Bool = false

    var body: some View {
        Group {
            ImportView(status: $status, alert: $alert)
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isHelpSheetShow.toggle()
                } label: {
                    Image(systemSymbol: .questionmarkCircle)
                }
            }
        })
        .sheet(isPresented: $isHelpSheetShow, content: {
            HelpSheet(isShow: $isHelpSheetShow)
        })
        .navigationTitle("app.gacha.import.uigf")
        .onChange(of: status, perform: { newValue in
            if case .succeed = newValue {
                isCompleteAlertShow.toggle()
            }
        })
        .toast(isPresenting: $isCompleteAlertShow, alert: {
            .init(
                displayMode: .alert,
                type: .complete(.green),
                title: "app.gacha.import.success".localized
            )
        })
        .alert(
            "gacha.import.startImport".localized,
            isPresented: isReadyToStartAlertShow,
            presenting: alert,
            actions: { thisAlert in
                Button("sys.start", role: .destructive, action: {
                    switch thisAlert {
                    case let .readyToStartJson(url: url, obsoleteFormat: obsoleteFormat):
                        processJson(url: url, obsoleteFormat: obsoleteFormat)
                    case let .readyToStartXlsx(url: url):
                        processXlsx(url: url)
                    }
                })
                Button("sys.cancel", role: .cancel, action: { alert = nil })

            },
            message: { _ in
                Text("gacha.import.informThatItNeedsWait")
            }
        )
    }

    func processJson(url: URL, obsoleteFormat: Bool) {
        DispatchQueue.global(qos: .userInteractive).async {
            status = .reading
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if url.startAccessingSecurityScopedResource() {
                do {
                    let decoder = JSONDecoder()
                    decoder
                        .keyDecodingStrategy =
                        .convertFromSnakeCase
                    let data: Data = try Data(contentsOf: url)
                    let uigfModel: UIGFv4
                    if !obsoleteFormat {
                        uigfModel = try decoder.decode(UIGFv4.self, from: data)
                    } else {
                        let uigfObsolete = try decoder.decode(UIGFv2.self, from: data)
                        uigfModel = .init(
                            info: .init(),
                            giProfiles: [uigfObsolete.upgradeTo4thGenerationProfile()]
                        )
                    }
                    let result = gachaViewModel.importGachaFromUIGFJson(uigfJson: uigfModel)
                    status = .succeed(ImportSucceedInfo(
                        uid: result.uid,
                        totalCount: result.totalCount,
                        newCount: result.newCount,
                        app: uigfModel.info.exportApp,
                        exportDate: Date(
                            timeIntervalSince1970: Double(uigfModel.info.exportTimestamp) ?? -1
                        )
                    ))
                    isCompleteAlertShow.toggle()
                } catch {
                    status = .failure(error.localizedDescription)
                }
                url.stopAccessingSecurityScopedResource()
            } else {
                status = .failure("app.gacha.import.fail.fileAccessFail".localized)
            }
        }
    }

    func processXlsx(url: URL) {
        DispatchQueue.global(qos: .userInteractive).async {
            status = .reading
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if url.startAccessingSecurityScopedResource() {
                do {
                    guard let file = XLSXFile(filepath: url.relativePath),
                          let workbook = try file.parseWorkbooks().first,
                          let (_, path) = try file.parseWorksheetPathsAndNames(workbook: workbook)
                          .first(where: { name, _ in
                              name == "原始数据"
                          }),
                          let worksheet = try? file.parseWorksheet(at: path),
                          let sharedStrings = try file.parseSharedStrings()
                    else {
                        status = .failure("app.gacha.import.fail.rawDataNotExist".localized); return
                    }
                    guard let head = worksheet.data?.rows.first?.cells
                        .map({ $0.stringValue(sharedStrings) }),
                        let rows = worksheet.data?.rows[1...]
                        .map({ $0.cells.map { $0.stringValue(sharedStrings) }}),
                        let gachaTypeIndex = head.firstIndex(where: { $0 == "gacha_type" }),
                        let itemTypeIndex = head.firstIndex(where: { $0 == "item_type" }),
                        let nameIndex = head.firstIndex(where: { $0 == "name" }),
                        let uidIndex = head.firstIndex(where: { $0 == "uid" }) else {
                        status = .failure("app.gacha.import.fail.dataTableMissingData".localized); return
                    }
                    let idIndex = head.firstIndex(where: { $0 == "id" })
                    let itemIdIndex = head.firstIndex(where: { $0 == "item_id" })
                    let timeIndex = head.firstIndex(where: { $0 == "time" })
                    let langIndex = head.firstIndex(where: { $0 == "lang" })
                    let rankTypeIndex = head.firstIndex(where: { $0 == "rank_type" })
                    let countIndex = head.firstIndex(where: { $0 == "count" })
                    let items: [GachaItemFetched] = rows.compactMap { cells in
                        guard let uid = cells[uidIndex],
                              let gachaType = cells[gachaTypeIndex],
                              let itemType = cells[itemTypeIndex],
                              let name = cells[nameIndex]
                        else {
                            return nil
                        }
                        let id: String
                        if let idIndex = idIndex,
                           let idString = cells[idIndex] {
                            id = idString
                        } else {
                            id = ""
                        }
                        let itemId: String
                        if let itemIdIndex = itemIdIndex,
                           let itemIdString = cells[itemIdIndex],
                           !itemIdString.isEmpty {
                            itemId = itemIdString
                        } else {
                            itemId = ""
                        }

                        let count: String
                        if let countIndex = countIndex,
                           let countString = cells[countIndex] {
                            count = countString
                        } else {
                            count = "1"
                        }

                        let dateFormatter = DateFormatter.Gregorian()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let time: Date
                        if let timeIndex = timeIndex,
                           let timeString = cells[timeIndex],
                           let timeDate = dateFormatter.date(from: timeString) {
                            time = timeDate
                        } else {
                            time = .distantPast
                        }

                        let lang: GachaLanguageCode
                        if let langIndex = langIndex,
                           let langString = cells[langIndex],
                           let langCode = GachaLanguageCode(rawValue: langString) {
                            lang = langCode
                        } else {
                            lang = .zhHans
                        }

                        let rankType: String
                        if let rankTypeIndex = rankTypeIndex,
                           let rankTypeString = cells[rankTypeIndex] {
                            rankType = rankTypeString
                        } else {
                            rankType = "3"
                        }

                        return GachaItemFetched(
                            uid: uid,
                            gachaType: gachaType,
                            itemId: itemId,
                            count: count,
                            time: time,
                            name: name,
                            lang: lang,
                            itemType: itemType,
                            rankType: rankType,
                            id: id
                        )
                    }
                    let newCount = gachaViewModel.manager.addRecordItems(items)
                    if !items.isEmpty {
                        status = .succeed(.init(uid: items.first!.uid, totalCount: items.count, newCount: newCount))
                    } else {
                        status = .failure("app.gacha.import.fail.decodeError".localized)
                    }
                } catch {
                    status = .failure(error.localizedDescription)
                }
                url.stopAccessingSecurityScopedResource()
            } else {
                status = .failure("app.gacha.import.fail.fileAccessFail")
            }
        }
    }

    // MARK: Fileprivate

    @State
    fileprivate var status: ImportStatus = .pending

    fileprivate var isReadyToStartAlertShow: Binding<Bool> {
        .init {
            alert != nil
        } set: { newValue in
            if newValue == false {
                alert = nil
            }
        }
    }

    // MARK: Private

    @State
    private var alert: AlertType?

    private var dateFormatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        return fmt
    }
}

// MARK: - AlertType

private enum AlertType: Identifiable {
    case readyToStartJson(url: URL, obsoleteFormat: Bool)
    case readyToStartXlsx(url: URL)

    // MARK: Internal

    var id: String {
        switch self {
        case .readyToStartJson:
            return "readyToStart"
        case .readyToStartXlsx:
            return "readyToStartXlsx"
        }
    }
}

// MARK: - ImportStatus

private enum ImportStatus {
    case pending
    case reading
    case succeed(ImportSucceedInfo)
    case failure(String)
}

// MARK: Equatable

extension ImportStatus: Equatable {}

// MARK: Identifiable

extension ImportStatus: Identifiable {
    var id: String {
        switch self {
        case .pending:
            return "pending"
        case .reading:
            return "reading"
        case .succeed:
            return "succeed"
        case .failure:
            return "failure"
        }
    }
}

// MARK: - ImportSucceedInfo

private struct ImportSucceedInfo: Equatable {
    // MARK: Lifecycle

    init(uid: String, totalCount: Int, newCount: Int, app: String? = nil, exportDate: Date? = nil) {
        self.uid = uid
        self.totalCount = totalCount
        self.newCount = newCount
        self.app = app
        self.exportDate = exportDate
    }

    // MARK: Internal

    let uid: String
    let totalCount: Int
    let newCount: Int
    let app: String?
    let exportDate: Date?
}

extension UTType {
    public static var xlsx: UTType = .init(filenameExtension: "xlsx")!
}

// MARK: - ImportFileSourceType

private enum ImportFileSourceType {
    case UIGFJSON
    case paimonXlsx
}

// MARK: - HelpSheet

private struct HelpSheet: View {
    @Binding
    var isShow: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Link(destination: URL(string: "https://gi.pizzastudio.org/static/import_tiwatexiaozhushou")!) {
                        Text("gacha.link.howToImportFromTeyvatAssistant")
                    }
                    Link(destination: URL(string: "https://gi.pizzastudio.org/static/paimonmoe-export.pdf")!) {
                        Text("gacha.instruction.howToImportFromPaimonMoe")
                    }
                } header: {
                    Text("gacha.term.tutorial")
                }
                Section {
                    if Locale.isUILanguagePanChinese {
                        Link(
                            destination: URL(
                                string: "https://uigf.org/zh/partnership.html"
                            )!
                        ) {
                            Label(
                                "app.gacha.import.help.uigf.button",
                                systemSymbol: .appBadgeCheckmark
                            )
                        }
                    } else {
                        Link(
                            destination: URL(
                                string: "https://uigf.org/en/partnership.html"
                            )!
                        ) {
                            Label(
                                "app.gacha.import.help.uigf.button",
                                systemSymbol: .appBadgeCheckmark
                            )
                        }
                    }
                } footer: {
                    Text("app.gacha.explainBetaUIGF")
                }
            }
            .navigationTitle("sys.help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
                        isShow.toggle()
                    }
                }
            }
        }
    }
}

// MARK: - PopFileButton

private struct PopFileButton: View {
    /// localized key
    let title: String

    let allowedContentTypes: [UTType]

    let completion: (Result<URL, Error>) -> ()

    @State
    var isFileImporterShow: Bool = false

    var body: some View {
        Button(title.localized) {
            isFileImporterShow.toggle()
        }
        .fileImporter(isPresented: $isFileImporterShow, allowedContentTypes: allowedContentTypes) { result in
            completion(result)
        }
    }
}

// MARK: - StatusView

private struct StatusView<V: View>: View {
    @Binding
    var status: ImportStatus
    @ViewBuilder
    var pendingForImportView: () -> V

    var body: some View {
        List {
            switch status {
            case .pending:
                pendingForImportView()
            case .reading:
                ReadingView()
            case let .succeed(info):
                SucceedView(status: $status, info: info)
            case let .failure(string):
                FailureView(status: $status, errorMessage: string)
            }
        }
    }
}

// MARK: - FailureView

private struct FailureView: View {
    @Binding
    var status: ImportStatus
    let errorMessage: String

    var body: some View {
        Text("app.gacha.import.fail")
        let errorContent = String(format: "app.gacha.import.errorContent:%@", errorMessage).localized
        Text(errorContent)
        Button("app.gacha.import.retry") {
            status = .pending
        }
    }
}

// MARK: - SucceedView

private struct SucceedView: View {
    // MARK: Internal

    @Binding
    var status: ImportStatus
    let info: ImportSucceedInfo

    var body: some View {
        Section {
            Label {
                Text("app.gacha.import.success")
            } icon: {
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
            }
            Text(verbatim: "UID: \(info.uid)")
            if let app = info.app {
                let sourceInfo = String(
                    format: "app.gacha.import.info.source:%@".localized,
                    app
                )
                Text(sourceInfo)
            }
            if let date = info.exportDate {
                let timeInfo = String(
                    format: "app.gacha.import.info.time:%@".localized,
                    dateFormatter.string(from: date)
                )
                Text(timeInfo)
            }
        }
        Section {
            let importInfo = String(
                format: "app.gacha.import.info.import:%lld".localized,
                info.totalCount
            )
            let storageInfo = String(
                format: "app.gacha.import.info.storage:%lld".localized,
                info.newCount
            )
            Text(importInfo)
            Text(storageInfo)
        }
        Button("app.gacha.import.continue") {
            status = .pending
        }
    }

    // MARK: Private

    private var dateFormatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        return fmt
    }
}

// MARK: - ReadingView

private struct ReadingView: View {
    var body: some View {
        Label {
            Text("app.gacha.import.working")
        } icon: {
            ProgressView()
        }
    }
}

// MARK: - ImportView

@available(iOS 16.0, *)
private struct ImportView: View {
    @Binding
    var status: ImportStatus
    @Binding
    var alert: AlertType?

    var body: some View {
        StatusView(status: $status) {
            Section {
                PopFileButton(title: "app.gacha.import.uigf.json", allowedContentTypes: [.json]) { result in
                    switch result {
                    case let .success(url):
                        alert = .readyToStartJson(url: url, obsoleteFormat: false)
                    case let .failure(error):
                        status = .failure(error.localizedDescription)
                    }
                }
            } footer: {
                Text("app.gacha.explainBetaUIGF")
                    + Text(verbatim: "\n\n")
                    + Text("app.gacha.import.uigf.verified.note.1")
            }
            Section {
                PopFileButton(title: "app.gacha.import.gigf.json", allowedContentTypes: [.json]) { result in
                    switch result {
                    case let .success(url):
                        alert = .readyToStartJson(url: url, obsoleteFormat: true)
                    case let .failure(error):
                        status = .failure(error.localizedDescription)
                    }
                }
                PopFileButton(title: "app.gacha.import.gigf.xlsx", allowedContentTypes: [.xlsx]) { result in
                    switch result {
                    case let .success(url):
                        alert = .readyToStartXlsx(url: url)
                    case let .failure(error):
                        status = .failure(error.localizedDescription)
                    }
                }
            } header: {
                Text("app.gacha.import.uigf.deprecatedFormats.header")
            } footer: {
                Text("app.gacha.import.uigf.deprecatedFormats.whySupported")
            }
        }
    }
}
