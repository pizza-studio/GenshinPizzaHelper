//
//  GetGachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import AlertToast
import Charts
import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI

// MARK: - APIGetGachaView

struct APIGetGachaView: View {
    // MARK: Internal

    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: true
    )])
    var accounts: FetchedResults<AccountConfiguration>
    @StateObject
    var gachaViewModel: GachaViewModel = .shared
    @StateObject
    var observer: GachaFetchProgressObserver = .shared

    @State
    var status: GetGachaStatus = .waitToStart
    @State
    var account: String?

    @State
    var isCompleteGetGachaRecordAlertShow: Bool = false
    @State
    var isErrorGetGachaRecordAlertShow: Bool = false

    var acountConfigsFiltered: [AccountConfiguration] {
        accounts.compactMap {
            guard $0.server.region == .mainlandChina else { return nil }
            return $0
        }
    }

    var body: some View {
        List {
            listContents()
        }
        .navigationTitle("app.gacha.get.title")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(status == .running)
        .environmentObject(observer)
        .onChange(of: status, perform: { newValue in
            switch newValue {
            case .succeed:
                isCompleteGetGachaRecordAlertShow.toggle()
            case .failure:
                isErrorGetGachaRecordAlertShow.toggle()
            default:
                break
            }
        })
        .toast(isPresenting: $isCompleteGetGachaRecordAlertShow, alert: {
            .init(
                displayMode: .alert,
                type: .complete(.green),
                title: "app.gacha.get.success".localized,
                subTitle: String(localized: "gacha.messages.newEntriesSaved:\(observer.newItemCount)")
            )
        })
        .toast(isPresenting: $isErrorGetGachaRecordAlertShow, alert: {
            guard case let .failure(error) = status
            else { return .init(displayMode: .alert, type: .loading) }
            let errorTitle = String(localized: "app.gacha.get.error:\(error.localizedDescription)")
            return .init(
                displayMode: .alert,
                type: .error(.red),
                title: errorTitle
            )
        })
    }

    // MARK: Private

    private var shouldShowGlobalServerNotice: Bool {
        accounts.map(\.server.region).contains(.global)
    }

    private var accountPickerPairs: [(value: String, tag: String?)] {
        var result = [(value: String, tag: String?)]()
        if account == nil {
            result.append(("app.gacha.account.select.notSelected", nil))
        }
        result.append(contentsOf: acountConfigsFiltered.map {
            ("\($0.name!) (\($0.uid!))", $0.uid!)
        })
        return result
    }

    @MainActor
    private func accountRefreshOnNil() {
        if account == nil {
            account = accounts.filter { $0.server.region != .global }.first?.uid
        }
    }

    @ViewBuilder
    private func listContents() -> some View {
        if status != .running {
            Section {
                accountPicker().onAppear {
                    accountRefreshOnNil()
                }
                Button("app.gacha.get.title") {
                    getGacha()
                }
                .disabled(account == nil)
                GetGachaURLByAPIButton(accountUID: account)
            } footer: {
                if shouldShowGlobalServerNotice {
                    Text("app.gacha.note.globalServers")
                }
            }
        } else {
            GettingGachaBar()
        }
        GetGachaResultView(status: $status)
    }

    @ViewBuilder
    private func accountPicker() -> some View {
        Picker("app.gacha.account.select.title", selection: $account) {
            Group {
                ForEach(accountPickerPairs, id: \.tag) { value, tag in
                    Text(value).tag(tag)
                }
            }
        }
    }

    @MainActor
    private func getGacha() {
        guard let account else { return }
        let firstAccount = accounts.first(where: { $0.uid == account })
        guard let firstAccount else { return }
        observer.initialize()
        status = .running
        gachaViewModel.getGachaAndSaveFor(firstAccount, observer: observer) { result in
            switch result {
            case .success:
                withAnimation {
                    status = .succeed
                }
            case let .failure(error):
                withAnimation {
                    status = .failure(error)
                }
            }
        }
    }
}

// MARK: - GetGachaURLByAPIButton

private struct GetGachaURLByAPIButton: View {
    enum Status {
        case ready
        case fetching
    }

    enum AlertType: Identifiable {
        case succeed(url: String)
        case failure(message: String)

        // MARK: Internal

        var id: String {
            switch self {
            case let .succeed(url: url):
                return "SUCCEED: \(url)"
            case let .failure(message: message):
                return "FAILURE: \(message)"
            }
        }
    }

    let accountUID: String?

    @State
    var alert: AlertType?

    @State
    var status: Status = .ready

    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: true
    )])
    var accounts: FetchedResults<AccountConfiguration>

    var body: some View {
        Button {
            genGachaURLByAPI(
                account: accounts.first(where: { $0.uid! == accountUID })!
            ) { result in
                status = .ready
                switch result {
                case let .success(urlString):
                    UIPasteboard.general.string = urlString
                    alert = .succeed(url: urlString)
                case let .failure(error):
                    alert = .failure(message: error.localizedDescription)
                }
            }
        } label: {
            switch status {
            case .ready:
                Text("gacha.link.generateWishLinkToClipboard")
            case .fetching:
                Label {
                    Text("gacha.fetch.pleaseWaitWhileFetchingTheWishLink")
                } icon: {
                    ProgressView()
                }
            }
        }
        .disabled((accountUID == nil) || (status == .fetching))
        .alert(item: $alert) { alert in
            switch alert {
            case let .succeed(url: url):
                return Alert(
                    title: Text("gacha.api.result.succeededInCopyingSourceLinkToClipboard"),
                    message: Text(url)
                )
            case let .failure(message: message):
                return Alert(title: Text("gacha.fetch.failedInGeneratingTheWishLink"), message: Text("失败信息：\(message)"))
            }
        }
    }

    func genGachaURLByAPI(
        account: AccountConfiguration,
        completion: @escaping (
            (Result<String, GenGachaURLError>) -> ()
        )
    ) {
        MihoyoAPI.genAuthKey(account: account) { result in
            if let result = try? result.get() {
                if result.retcode == 0 {
                    let urlString = genGachaURLString(
                        server: account.server,
                        authkey: result.data!,
                        gachaType: .character,
                        page: 1,
                        endId: "0"
                    )
                    completion(.success(
                        urlString
                    ))
                } else {
                    completion(.failure(.genURLError(message: "fail to get auth key: \(result.message)")))
                }
            } else {
                completion(.failure(.genURLError(message: "fail to get auth key")))
            }
        }
    }
}

// MARK: - GachaItemBar

private struct GachaItemBar: View {
    let item: GachaItem_FM

    var body: some View {
        VStack(spacing: 1) {
            HStack {
                Label {
                    Text(item.localizedName)
                } icon: {
                    item.decoratedIconView(30, cutTo: .face)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(
                        _GachaType(rawValue: Int(item.gachaType)!)!
                            .localizedDescription()
                    )
                    .font(.caption)
                    Text("\(item.formattedTime)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - GetGachaChart

@available(iOS 16.0, *)
private struct GetGachaChart: View {
    let items: [GachaItem_FM]

    let data: [GachaTypeDateCount]

    let formatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .none
        return fmt
    }()

    var body: some View {
        Chart(data) {
            LineMark(
                x: .value("sys.date", $0.date),
                y: .value("sys.pull", $0.count)
            )
            .foregroundStyle(by: .value("app.gacha.label.gachaType", $0.type.localizedDescription()))
        }
        .chartForegroundStyleScale([
            GachaType.standard.localizedDescription(): .green,
            GachaType.character.localizedDescription(): .blue,
            GachaType.weapon.localizedDescription(): .yellow,
            GachaType.chronicled.localizedDescription(): .purple,
        ])
//        .chartXAxis {
//            AxisMarks { value in
//                AxisValueLabel(content: {
//                    if let date = value.as(Date.self) {
//                        Text(formatter.string(from: date))
//                    } else {
//                        EmptyView()
//                    }
//                })
//            }
//        }
    }
}

// MARK: - GettingGachaBar

struct GettingGachaBar: View {
    @EnvironmentObject
    var observer: GachaFetchProgressObserver

    var body: some View {
        Section {
            HStack {
                ProgressView()
                Spacer()
                Text("app.gacha.get.info.waiting")
                Spacer()
                Button {
                    observer.shouldCancel = true
                } label: {
                    Image(systemSymbol: .squareCircle)
                }
            }
        } footer: {
            HStack {
                VStack(alignment: .leading) {
                    Text("app.gacha.get.info.pool:\(observer.gachaType.localizedDescription())")
                    Text("app.gacha.get.info.page:\(observer.page.description)")
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("app.gacha.get.info.record:\(observer.currentItems.count.description)")
                    Text("app.gacha.get.info.record.new:\(observer.newItemCount.description)")
                }
            }
        }
    }
}

// MARK: - GetGachaStatus

enum GetGachaStatus: Equatable {
    case waitToStart
    case running
    case succeed
    case failure(GetGachaError)
}

// MARK: - GetGachaResultView

struct GetGachaResultView: View {
    @EnvironmentObject
    var observer: GachaFetchProgressObserver

    @Binding
    var status: GetGachaStatus

    var body: some View {
        if #available(iOS 16.0, *) {
            if (status == .succeed) || (status == .running) {
                Section {
                    GetGachaChart(
                        items: observer.currentItems,
                        data: observer.gachaTypeDateCounts
                            .sorted(by: { $0.date > $1.date })
                    )
                    .padding(.vertical)
                }
            }
        }

        if status == .succeed {
            Section {
                Label {
                    Text("app.gacha.get.success")
                } icon: {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                }
            } footer: {
                Text(
                    "app.gacha.get.result:\(observer.currentItems.count.description)\(observer.newItemCount.description)"
                )
            }
        }

        switch status {
        case .running, .succeed:
            let items = observer.currentItems
            if !items.isEmpty {
                Section {
                    ForEach(items.reversed()) { item in
                        GachaItemBar(item: item)
                    }
                } header: {
                    Text(status == .running ? "app.gacha.get.running" : "")
                }
            }
        case let .failure(error):
            Section {
                Label {
                    Text("app.gacha.get.info.fail")
                } icon: {
                    Image(systemSymbol: .xmarkCircle)
                        .foregroundColor(.red)
                }
                Text("ERROR: \(error.localizedDescription)")
            }
        default:
            EmptyView()
        }

        EmptyView()
            .onChange(of: status) { _ in
                if case .running = status {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        ReviewHandler.requestReview()
                    }
                }
            }
    }
}
