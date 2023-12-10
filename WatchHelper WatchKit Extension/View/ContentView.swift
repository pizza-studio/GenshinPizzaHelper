//
//  ContentView.swift
//  WatchHelper WatchKit Extension
//
//  Created by Bill Haku on 2022/9/8.
//

import Combine
import Defaults
import HoYoKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

let testCookie =
    "stuid=114514004; stoken=SANITIZED ltuid=114514004; ltoken=SANITIZED "

// MARK: - ContentView

private let refreshSubject: PassthroughSubject<(), Never> = .init()

// MARK: - ContentView

struct ContentView: View {
    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: true
    )])
    var accounts: FetchedResults<AccountConfiguration>

    @Environment(\.scenePhase)
    var scenePhase

    @Environment(\.managedObjectContext)
    var viewContext

    var body: some View {
        NavigationStack {
            if accounts.isEmpty {
                VStack {
                    Text("请等待账号从iCloud同步")
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                    Image(systemSymbol: .icloudAndArrowDown)
                    ProgressView()
                }
            } else {
                List {
                    ForEach(
                        accounts,
                        id: \.safeUuid
                    ) { account in
                        DetailNavigator(account: account)
                    }
                    NavigationLink("nav.category.settings.name") {
                        WatchWidgetSettingView()
                    }
                }
                .listStyle(.carousel)
                .refreshable {
                    refreshSubject.send(())
                }
            }
        }
        .onChange(of: scenePhase, perform: { newPhase in
            switch newPhase {
            case .inactive:
                if #available(watchOSApplicationExtension 9.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                    WidgetCenter.shared.invalidateConfigurationRecommendations()
                }
            default:
                break
            }
        })
//        .onAppear {
//            let account = AccountConfiguration(context: viewContext)
//            account.name = "Lava"
//            account.server = .china
//            account.cookie = testCookie
//        }
    }
}

// MARK: - DetailNavigator

private struct DetailNavigator: View {
    // MARK: Lifecycle

    init(account: AccountConfiguration) {
        self._dailyNoteViewModel = .init(wrappedValue: DailyNoteViewModel(account: account))
    }

    // MARK: Internal

    @Environment(\.scenePhase)
    var scenePhase

    var account: AccountConfiguration { dailyNoteViewModel.account }

    var body: some View {
        Group {
            switch dailyNoteViewModel.dailyNoteStatus {
            case .progress:
                ProgressView()
            case let .failure(error: error):
                Button {
                    dailyNoteViewModel.getDailyNoteUncheck()
                } label: {
                    Label {
                        Text(error.localizedDescription)
                    } icon: {
                        Image(systemSymbol: .exclamationmarkCircle)
                            .foregroundColor(.red)
                    }
                }
            case let .succeed(dailyNote: dailyNote, refreshDate: _):
                NavigationLink {
                    WatchAccountDetailView(data: dailyNote, accountName: account.safeName, uid: account.safeUid)
                } label: {
                    HStack {
                        VStack {
                            Text(account.safeName).font(.headline)
                            HStack {
                                Image("树脂").resizable().scaledToFit()
                                    .frame(width: 25, height: 25)
                                Text("\(dailyNote.resinInformation.currentResin)")
                            }
                        }
                        Spacer()
                        Image(systemSymbol: .chevronRight)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onReceive(refreshSubject) { _ in
            dailyNoteViewModel.getDailyNoteUncheck()
        }
        .onAppear {
            dailyNoteViewModel.getDailyNote()
        }
    }

    // MARK: Private

    @StateObject
    private var dailyNoteViewModel: DailyNoteViewModel
}

// MARK: - DailyNoteViewModel

class DailyNoteViewModel: ObservableObject {
    // MARK: Lifecycle

    /// Initializes a new instance of the view model.
    ///
    /// - Parameter account: The account for which the daily note will be fetched.
    init(account: AccountConfiguration) {
        self.account = account
        Task {
            await getDailyNoteUncheck()
        }
    }

    // MARK: Internal

    enum Status {
        case succeed(dailyNote: any DailyNote, refreshDate: Date)
        case failure(error: AnyLocalizedError)
        case progress(Task<(), Never>?)
    }

    /// The current daily note.
    @Published
    private(set) var dailyNoteStatus: Status = .progress(nil)

    /// The account for which the daily note is being fetched.
    let account: AccountConfiguration

    /// Fetches the daily note and updates the published `dailyNote` property accordingly.
    @MainActor
    func getDailyNote() {
        if case let .succeed(_, refreshDate) = dailyNoteStatus {
            // check if note is older than 15 minutes
            let shouldUpdateAfterMinute: Double = 15
            let shouldUpdateAfterSecond = 60.0 * shouldUpdateAfterMinute

            if Date().timeIntervalSince(refreshDate) > shouldUpdateAfterSecond {
                getDailyNoteUncheck()
            }
        } else if case .progress = dailyNoteStatus {
            return // another operation is already in progress
        } else {
            getDailyNoteUncheck()
        }
    }

    /// Asynchronously fetches the daily note using the MiHoYoAPI with the account information it was initialized with.
    @MainActor
    func getDailyNoteUncheck() {
        if case let .progress(task) = dailyNoteStatus {
            task?.cancel()
        }
        let task = Task {
            do {
                let result = try await account.dailyNote()
                withAnimation {
                    dailyNoteStatus = .succeed(dailyNote: result, refreshDate: Date())
                }
            } catch {
                withAnimation {
                    dailyNoteStatus = .failure(error: AnyLocalizedError(error))
                }
            }
        }
        dailyNoteStatus = .progress(task)
    }
}
