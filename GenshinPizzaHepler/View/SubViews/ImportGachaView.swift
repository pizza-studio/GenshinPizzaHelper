//
//  ImportGachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/4/2.
//

import AlertToast
import SwiftUI
import UniformTypeIdentifiers

// MARK: - ImportGachaView

struct ImportGachaView: View {
    // MARK: Internal

    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    @State
    var isFileImporterShow: Bool = false

    @State
    var isHelpSheetShow: Bool = false

    @State
    var isCompleteAlertShow: Bool = false

    var body: some View {
        List {
            switch status {
            case .pending:
                Section {
                    Button("导入UIGF Json格式祈愿记录") {
                        isFileImporterShow.toggle()
                    }
                } footer: {
                    Text("目前仅支持Json格式的祈愿记录")
                }
            case .reading:
                Label {
                    Text("导入中，请稍后...")
                } icon: {
                    ProgressView()
                }
            case let .succeed(info):
                Section {
                    Label {
                        Text("导入祈愿数据成功")
                    } icon: {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                    }
                    Text("UID: \(info.uid)")
                    if let app = info.app {
                        Text("数据来自：\(app)")
                    }
                    if let date = info.exportDate {
                        Text("导出时间：\(dateFormatter.string(from: date))")
                    }
                }
                Section {
                    Text("导入了\(info.totalCount)条记录")
                    Text("储存了\(info.newCount)条新纪录")
                }
                Button("继续导入") {
                    isFileImporterShow.toggle()
                    status = .pending
                }
            case let .failure(string):
                Text("导入失败")
                Text("错误信息：\(string)")
                Button("重试") {
                    isFileImporterShow.toggle()
                    status = .pending
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isHelpSheetShow.toggle()
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        })
        .sheet(isPresented: $isHelpSheetShow, content: {
            HelpSheet(isShow: $isHelpSheetShow)
        })
        .navigationTitle("导入UIGF祈愿记录")
        .fileImporter(
            isPresented: $isFileImporterShow,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case let .success(url):
                alert = .readyToStart(url: url)
            case let .failure(error):
                status = .failure(error.localizedDescription)
            }
        }
        .toast(isPresenting: $isCompleteAlertShow, alert: {
            .init(
                displayMode: .alert,
                type: .complete(.green),
                title: "成功导入祈愿数据"
            )
        })
        .alert(item: $alert) { alert in
            switch alert {
            case let .readyToStart(url: url):
                return Alert(
                    title: Text("导入时界面会卡住一段时间"),
                    message: Text("请耐心等待..."),
                    primaryButton: .destructive(Text("开始"), action: {
                        do {
                            if url.startAccessingSecurityScopedResource() {
                                status = .reading
                                let decoder = JSONDecoder()
                                decoder
                                    .keyDecodingStrategy = .convertFromSnakeCase
                                let data: Data = try Data(contentsOf: url)
                                let uigfModel: UIGFJson = try decoder.decode(
                                    UIGFJson.self,
                                    from: data
                                )
                                let result = gachaViewModel
                                    .importGachaFromUIGFJson(
                                        uigfJson: uigfModel
                                    )
                                status = .succeed(ImportSucceedInfo(
                                    uid: result.uid,
                                    totalCount: result.totalCount,
                                    newCount: result.newCount,
                                    app: uigfModel.info.exportApp,
                                    exportDate: uigfModel.info.exportTime
                                ))
                                isCompleteAlertShow.toggle()
                                url.stopAccessingSecurityScopedResource()
                            } else {
                                status = .failure("无法访问文件")
                            }
                        } catch {
                            status = .failure(error.localizedDescription)
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
        }
    }

    // MARK: Fileprivate

    @State
    fileprivate var status: ImportStatus = .pending

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
    case readyToStart(url: URL)

    // MARK: Internal

    var id: String {
        switch self {
        case .readyToStart:
            return "readyToStart"
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

private struct ImportSucceedInfo {
    let uid: String
    let totalCount: Int
    let newCount: Int
    let app: String?
    let exportDate: Date?
}

// MARK: - HelpSheet

private struct HelpSheet: View {
    @Binding
    var isShow: Bool

    var body: some View {
        NavigationView {
            List {
                if Locale.current.languageCode == "zh" {
                    Link(
                        destination: URL(
                            string: "https://uigf.org/zh/partnership.html"
                        )!
                    ) {
                        Label(
                            "支持UIGF的软件",
                            systemImage: "app.badge.checkmark"
                        )
                    }
                } else {
                    Link(
                        destination: URL(
                            string: "https://uigf.org/en/partnership.html"
                        )!
                    ) {
                        Label(
                            "支持UIGF的软件",
                            systemImage: "app.badge.checkmark"
                        )
                    }
                }
            }
            .navigationTitle("导入帮助")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        isShow.toggle()
                    }
                }
            }
        }
    }
}
