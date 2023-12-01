//
//  HomeView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//  展示所有账号的主页

import AlertToast
import Defaults
import HBMihoyoAPI
import HoYoKit
import SFSafeSymbols
import SwiftUI

// MARK: - NewHomeView

struct NewHomeView: View {
    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: false
    )])
    var accounts: FetchedResults<AccountConfiguration>

    var body: some View {
        NavigationView {
            List {
                TodayMaterialView()
                ForEach(accounts) { account in
                    AccountInfoCardView(account: account)
                }
            }
            .refreshable {
                globalDailyNoteCardRefreshSubject.send(())
            }
        }
    }
}

// MARK: - AccountInfoCardView

struct AccountInfoCardView: View {
    enum Status {
        case succeed(dailyNote: GeneralDailyNote)
        case failure(error: AnyLocalizedError)
        case progress(Task<(), Never>?)
    }

    struct NoteView: View {
        // MARK: Internal

        let dailyNote: GeneralDailyNote
        let account: AccountConfiguration

        var body: some View {
            VStack {
                HStack {
                    Text("Resin").bold()
                    Spacer()
                }
                HStack(spacing: 10) {
                    let iconFrame: CGFloat = 40
                    Image("树脂")
                        .resizable()
                        .scaledToFit()
                        .frame(height: iconFrame)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(verbatim: "\(dailyNote.resinInformation.currentResin)")
                            .font(.title)
                        Text(verbatim: " / \(dailyNote.resinInformation.maxResin)")
                            .font(.caption)
                        Spacer()
                        if dailyNote.resinInformation.resinRecoveryTime > Date() {
                            (
                                Text(dailyNote.resinInformation.resinRecoveryTime, style: .relative)
                                    + Text(verbatim: "\n")
                                    + Text(dateFormatter.string(from: dailyNote.resinInformation.resinRecoveryTime))
                            )
                            .multilineTextAlignment(.trailing)
                            .font(.caption2)
                        }
                    }
                }
            }
        }

        // MARK: Private

        private let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateFormatter.doesRelativeDateFormatting = true
            return dateFormatter
        }()
    }

    let account: AccountConfiguration

    @State
    var status: Status = .progress(nil)

    @Environment(\.scenePhase)
    var scenePhase

    var body: some View {
        Section {
            switch status {
            case let .succeed(dailyNote):
                NoteView(dailyNote: dailyNote, account: account)
            case let .failure(error):
                Text(error.localizedDescription)
            case .progress:
                ProgressView()
            }
        }
        .onChange(of: scenePhase, perform: { newPhase in
            switch newPhase {
            case .active:
                fetchDailyNote()
            default:
                break
            }
        })
        .onReceive(globalDailyNoteCardRefreshSubject, perform: { _ in
            fetchDailyNote()
        })
    }

    func fetchDailyNote() {
        if case let .progress(task) = status { task?.cancel() }
        let task = Task {
            do {
                status = .succeed(dailyNote: try await MiHoYoAPI.generalDailyNote(
                    server: account.server,
                    uid: account.safeUid,
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.safeDeviceFingerPrint,
                    deviceId: account.safeUuid
                ))
            } catch {
                status = .failure(error: AnyLocalizedError(error))
            }
        }
        status = .progress(task)
    }
}

// MARK: - TodayMaterialView

struct TodayMaterialView: View {
    @Environment(\.scenePhase)
    var scenePhase

    @State
    var eventContents: [EventModel] = []

    var body: some View {
        Section {
            InAppMaterialNavigator()
                .onChange(of: scenePhase, perform: { newPhase in
                    switch newPhase {
                    case .active:
                        getCurrentEvent()
                    default:
                        break
                    }
                })
                .onAppear {
                    if eventContents.isEmpty {
                        getCurrentEvent()
                    }
                }
        }
        Section {
            CurrentEventNavigator(eventContents: $eventContents)
        }
    }

    func getCurrentEvent() {
        DispatchQueue.global().async {
            API.OpenAPIs.fetchCurrentEvents { result in
                switch result {
                case let .success(events):
                    withAnimation {
                        eventContents = [EventModel](events.event.values)
                        eventContents = eventContents.sorted {
                            $0.endAt < $1.endAt
                        }
                    }
                case .failure:
                    break
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func myRefreshable(action: @escaping () -> ()) -> some View {
        refreshable {
            action()
        }
    }
}
