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
import NaturalLanguage
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
                    let appMeta = uigfModel.info.exportApp
                    let dateMeta = uigfModel.info.maybeDateExported
                    let results = gachaViewModel.importGachaFromUIGFJson(uigfJson: uigfModel)

                    var succeededMessages: [ImportSucceedInfo] = []
                    results.forEach { currentMsg in
                        succeededMessages.append(
                            ImportSucceedInfo(
                                uid: currentMsg.uid,
                                totalCount: currentMsg.totalCount,
                                newCount: currentMsg.newCount,
                                app: appMeta,
                                exportDate: dateMeta,
                                timeZone: GachaItem.getServerTimeZoneDelta(currentMsg.uid)
                            )
                        )
                    }
                    status = .succeed(succeededMessages)
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
        DispatchQueue.global(qos: .userInteractive).async { status = .reading }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if url.startAccessingSecurityScopedResource() {
                do {
                    guard let file = XLSXFile(filepath: url.relativePath) else {
                        status = .failure("app.gacha.import.fail.rawDataNotExist".localized); return
                    }
                    let uigfModel = try file.parseItems()
                    let results = gachaViewModel.importGachaFromUIGFJson(uigfJson: uigfModel)
                    var succeededMessages: [ImportSucceedInfo] = []
                    results.forEach { currentMsg in
                        succeededMessages.append(
                            ImportSucceedInfo(
                                uid: currentMsg.uid,
                                totalCount: currentMsg.totalCount,
                                newCount: currentMsg.newCount,
                                timeZone: GachaItem.getServerTimeZoneDelta(currentMsg.uid)
                            )
                        )
                    }
                    if !results.isEmpty {
                        status = .succeed(succeededMessages)
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
    case succeed([ImportSucceedInfo])
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

private struct ImportSucceedInfo: Equatable, Identifiable {
    // MARK: Lifecycle

    init(
        uid: String,
        totalCount: Int,
        newCount: Int,
        app: String? = nil,
        exportDate: Date? = nil,
        timeZone: Int
    ) {
        self.uid = uid
        self.totalCount = totalCount
        self.newCount = newCount
        self.app = app
        self.exportDate = exportDate
        self.timeZoneDelta = timeZone
    }

    // MARK: Internal

    let id = UUID().uuidString
    let uid: String
    let totalCount: Int
    let newCount: Int
    let app: String?
    let exportDate: Date?
    let timeZoneDelta: Int

    @ViewBuilder
    var timeView: some View {
        if let date = exportDate {
            VStack(alignment: .leading) {
                let timeInfo = String(
                    format: "app.gacha.import.info.time:%@".localized,
                    dateFormatterCurrent.string(from: date)
                )
                Text(timeInfo)
                if importedTimeZone.secondsFromGMT() != TimeZone.autoupdatingCurrent.secondsFromGMT() {
                    let timeInfo2 = "UTC\(timeZoneDeltaValueText): " + dateFormatterAsImported.string(from: date)
                    Text(timeInfo2).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    var timeViewSimple: some View {
        if let date = exportDate {
            let timeInfo = String(
                format: "app.gacha.import.info.time:%@".localized,
                dateFormatterCurrent.string(from: date)
            )
            Text(timeInfo)
        }
    }

    @ViewBuilder
    var timeZoneView: some View {
        Text(verbatim: "UTC\(timeZoneDeltaValueText)")
    }

    // MARK: Private

    private var timeZoneDeltaValueText: String {
        switch timeZoneDelta {
        case 0...: return "+\(timeZoneDelta)"
        default: return "\(timeZoneDelta)"
        }
    }

    private var importedTimeZone: TimeZone {
        .init(secondsFromGMT: 3600 * timeZoneDelta) ?? .autoupdatingCurrent
    }

    private var dateFormatterAsImported: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        return fmt
    }

    private var dateFormatterCurrent: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        fmt.timeZone = .init(secondsFromGMT: 3600 * timeZoneDelta)
        return fmt
    }
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
                    Text("app.gacha.explainUIGF")
                        + Text(verbatim: "\n\n")
                        + Text("app.gacha.uigf.affLink.[UIGF](https://uigf.org/)")
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
                SucceedView(status: $status, infoMsgs: info)
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
        let errorContent = String(format: "app.gacha.import.errorContent:%@".localized, errorMessage)
        Text(errorContent)
        Button("app.gacha.import.retry") {
            status = .pending
        }
    }
}

// MARK: - SucceedView

private struct SucceedView: View {
    @Binding
    var status: ImportStatus
    let infoMsgs: [ImportSucceedInfo]

    var body: some View {
        Section {
            Label {
                Text("app.gacha.import.success")
            } icon: {
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
            }
            if let app = infoMsgs.first?.app {
                let sourceInfo = String(format: "app.gacha.import.info.source:%@".localized, app)
                Text(sourceInfo)
            }
        } footer: {
            if let firstInfo = infoMsgs.first {
                firstInfo.timeViewSimple
            }
        }
        ForEach(infoMsgs, id: \.id) { info in
            Section {
                let importInfo = String(format: "app.gacha.import.info.import:%lld".localized, info.totalCount)
                let storageInfo = String(format: "app.gacha.import.info.storage:%lld".localized, info.newCount)
                Text(importInfo)
                Text(storageInfo)
            } header: {
                HStack {
                    Text(verbatim: "UID: \(info.uid)")
                    Spacer()
                    info.timeZoneView
                }
            }
        }
        Button("app.gacha.import.continue") {
            status = .pending
        }
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
                VStack(alignment: .leading, spacing: 11) {
                    Text("app.gacha.explainUIGF")
                    Text("app.gacha.uigf.affLink.[UIGF](https://uigf.org/)")
                    Text("app.gacha.import.uigf.verified.note.1")
                }.multilineTextAlignment(.leading)
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
                FallbackTimeZonePicker()
            } header: {
                Text("app.gacha.import.gigf.header")
            } footer: {
                VStack(alignment: .leading, spacing: 11) {
                    Text("app.gacha.import.gigf.whySupported")
                    Text("app.gacha.import.gigf.whySupported.timeZone")
                    Text("app.gacha.import.gigf.minimumSupportedVersion")
                }.multilineTextAlignment(.leading)
            }
        }
    }
}

// MARK: - FallbackTimeZonePicker

private struct FallbackTimeZonePicker: View {
    @Default(.fallbackTimeForGIGFFileImport)
    var fallbackTimeForGIGFFileImport: TimeZone?

    var body: some View {
        Picker("app.gacha.import.gigf.fallbackTimeZone", selection: $fallbackTimeForGIGFFileImport) {
            Text("app.gacha.import.gigf.fallbackTimeZone.autoDeduct").tag(TimeZone?.none)
            ForEach(tagPairs, id: \.1) { timeZoneName, identifier, timeZone in
                Text(verbatim: "\(timeZoneName) \(identifier)").monospacedDigit().tag(timeZone)
            }
        }
        .pickerStyle(.navigationLink)
    }

    var tagPairs: [(timeZoneName: String, identifier: String, timeZone: TimeZone?)] {
        var results: [(timeZoneName: String, identifier: String, timeZone: TimeZone)] = []
        TimeZone.knownTimeZoneIdentifiers.forEach { identifier in
            guard identifier != "GMT", let zone = TimeZone(identifier: identifier) else { return }
            let initialName = zone.localizedName(for: .shortDaylightSaving, locale: .autoupdatingCurrent) ?? "N/A"
            var timeZoneName: String = initialName == "GMT" ? "GMT+0" : initialName
            timeZoneName = timeZoneName.replacingOccurrences(of: "GMT", with: "UTC")
            var identifierCells = identifier.split(separator: "/")
            if identifierCells.count > 2 {
                identifierCells.remove(at: 0)
            }
            let newEntry = (timeZoneName, identifierCells.joined(separator: " / "), zone)
            results.append(newEntry)
        }
        results.insert(("UTC+0", "Snap Hutao Deprecated & GMT", TimeZone.gmt), at: 0)
        return results
    }
}
