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
                if accounts.isEmpty {
                    AddNewAccountButton()
                        .listRowBackground(Color.white.opacity(0))
                } else {
                    ForEach(accounts) { account in
                        AccountInfoCardView(account: account)
                    }
                }
            }
            .refreshable {
                globalDailyNoteCardRefreshSubject.send(())
            }
            .sectionSpacing(UIFont.systemFontSize)
            .navigationTitle("app.home.title")
        }
    }
}

// MARK: - AccountInfoCardView

struct AccountInfoCardView: View {
    enum Status {
        case succeed(dailyNote: any DailyNote)
        case failure(error: AnyLocalizedError)
        case progress(Task<(), Never>?)
    }

    struct NoteView: View {
        // MARK: Internal

        let dailyNote: any DailyNote
        let account: AccountConfiguration

        var body: some View {
            VStack {
                HStack {
                    Text("app.dailynote.card.resin.label").bold()
                    Spacer()
                }
                HStack(spacing: 10) {
                    Image("树脂")
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconFrame, height: iconFrame)
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
            // daily task
            VStack {
                let dailyTask = dailyNote.dailyTaskInformation
                HStack {
                    Text("app.dailynote.card.dailyTask.label").bold()
                    Spacer()
                }
                HStack(spacing: 10) {
                    Image("每日任务")
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconFrame, height: iconFrame)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(verbatim: "\(dailyTask.finishedTaskCount)")
                            .font(.title)
                        Text(verbatim: " / \(dailyTask.totalTaskCount)")
                            .font(.caption)
                        Spacer()
                        switch dailyTask.isExtraRewardReceived {
                        case true:
                            Text("app.dailynote.card.dailyTask.extraReward.received")
                        case false:
                            Text("app.dailynote.card.dailyTask.extraReward.notReceived")
                        }
                    }
                }
            }
            VStack {
                let homeCoin = dailyNote.homeCoinInformation
                HStack {
                    Text("app.dailynote.card.homeCoin.label").bold()
                    Spacer()
                }
                HStack(spacing: 10) {
                    Image("洞天宝钱")
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconFrame, height: iconFrame)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(verbatim: "\(homeCoin.currentHomeCoin)")
                            .font(.title)
                        Text(verbatim: " / \(homeCoin.maxHomeCoin)")
                            .font(.caption)
                        Spacer()
                        if homeCoin.fullTime > Date() {
                            (
                                Text(homeCoin.fullTime, style: .relative)
                                    + Text(verbatim: "\n")
                                    + Text(dateFormatter.string(from: homeCoin.fullTime))
                            )
                            .multilineTextAlignment(.trailing)
                            .font(.caption2)
                        }
                    }
                }
            }
            VStack {
                let expeditionInfo = dailyNote.expeditionInformation
                HStack {
                    Text("app.dailynote.card.expedition.label").bold()
                    Spacer()
                }
                HStack(spacing: 10) {
                    Image("派遣探索")
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconFrame, height: iconFrame)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(verbatim: "\(expeditionInfo.ongoingExpeditionCount)")
                            .font(.title)
                        Text(verbatim: " / \(expeditionInfo.maxExpeditionsCount)")
                            .font(.caption)
                        Spacer()
                        HStack {
                            ForEach(expeditionInfo.expeditions, id: \.iconURL) { expedition in
                                AsyncImage(url: expedition.iconURL) { image in
                                    GeometryReader { g in
                                        image.resizable().scaleEffect(1.4)
                                            .scaledToFit()
                                            .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
                                    }
                                } placeholder: {
                                    ProgressView().id(UUID())
                                }
                                .overlay(
                                    Circle()
                                        .stroke(expedition.isFinished ? .green : .secondary, lineWidth: 3)
                                )
                                .frame(width: 30, height: 30)
                            }
                        }
                    }
                }
            }
        }

        // MARK: Private

        private let iconFrame: CGFloat = 40

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
                ErrorView(account: account, error: error)
            case .progress:
                ProgressView()
            }
        } header: {
            Text(account.safeName)
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
                status = .succeed(dailyNote: try await account.dailyNote())
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

// MARK: - AddNewAccountButton

private struct AddNewAccountButton: View {
    // MARK: Internal

    @State
    var isNewAccountSheetShow: Bool = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Label("account.new", systemSymbol: .plusCircle)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.blue, lineWidth: 4)
                    )
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                    .contentShape(RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    ))
                    .clipShape(RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    ))
                    .onTapGesture {
                        isNewAccountSheetShow.toggle()
                    }
                    .sheet(isPresented: $isNewAccountSheetShow) {
                        CreateAccountSheetView(
                            account: AccountConfiguration(context: viewContext),
                            isShown: $isNewAccountSheetShow
                        )
                    }
                Spacer()
            }
        }
    }

    // MARK: Private

    @Environment(\.managedObjectContext)
    private var viewContext
}

// MARK: - ErrorView

private struct ErrorView: View {
    // MARK: Internal

    let account: AccountConfiguration
    var error: Error

    var body: some View {
        Button {
            isEditAccountSheetShown.toggle()
        } label: {
            switch error {
            case MiHoYoAPIError.verificationNeeded:
                Label {
                    Text("app.dailynote.card.error.need_verification.button")
                } icon: {
                    Image(systemSymbol: .questionmarkCircle)
                        .foregroundColor(.yellow)
                }
            default:
                Label {
                    Text("app.dailynote.card.error.other_error.button")
                } icon: {
                    Image(systemSymbol: .exclamationmarkCircle)
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $isEditAccountSheetShown, content: {
            EditAccountSheetView(account: account, isShown: $isEditAccountSheetShown)
        })
    }

    // MARK: Private

    @State
    private var isEditAccountSheetShown: Bool = false
}
