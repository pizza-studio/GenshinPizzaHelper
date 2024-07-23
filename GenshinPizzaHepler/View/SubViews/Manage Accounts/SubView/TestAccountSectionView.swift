//
//  TestAccountView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import Combine
import HoYoKit
import SwiftUI

struct TestAccountSectionView: View {
    // MARK: Internal

    let account: Account

    var body: some View {
        Section {
            Button {
                doTest()
            } label: {
                HStack {
                    Text("settings.account.testConnection")
                    Spacer()
                    buttonIcon()
                }
            }
            .disabled(status == .testing)
            if case let .failure(error) = status {
                FailureView(error: error)
            } else if status == .verificationNeeded {
                VerificationNeededView(account: account) {
                    doTest()
                }
            }
        }
        .onAppear {
            doTest()
        }
    }

    func doTest() {
        withAnimation {
            status = .testing
        }
        Task {
            do {
                _ = try await account.dailyNote()
                withAnimation {
                    status = .succeeded
                }
            } catch MiHoYoAPIError.verificationNeeded {
                withAnimation {
                    status = .verificationNeeded
                    verificationErrorHasOccurred = true
                }
            } catch {
                withAnimation {
                    status = .failure(error)
                }
            }
        }
    }

    @ViewBuilder
    func buttonIcon() -> some View {
        Group {
            switch status {
            case .succeeded:
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
            case .failure:
                Image(systemSymbol: .xmarkCircle)
                    .foregroundColor(.red)
            case .testing:
                ProgressView()
            case .verificationNeeded:
                Image(systemSymbol: .questionmarkCircle)
                    .foregroundColor(.yellow)
            default:
                EmptyView()
            }
        }
    }

    // MARK: Private

    private enum TestStatus: Identifiable, Equatable {
        case pending
        case testing
        case succeeded
        case failure(Error)
        case verificationNeeded

        // MARK: Internal

        var id: Int {
            switch self {
            case .pending:
                return 0
            case .testing:
                return 1
            case .succeeded:
                return 2
            case let .failure(error):
                return error.localizedDescription.hashValue
            case .verificationNeeded:
                return 4
            }
        }

        static func == (lhs: TestAccountSectionView.TestStatus, rhs: TestAccountSectionView.TestStatus) -> Bool {
            lhs.id == rhs.id
        }
    }

    private struct FailureView: View {
        let error: Error

        var body: some View {
            Text(error.localizedDescription)
            if let error = error as? LocalizedError {
                if let failureReason = error.failureReason {
                    Text(failureReason)
                }
                if let recoverySuggestion = error.recoverySuggestion {
                    Text(recoverySuggestion)
                }
            }
        }
    }

    private struct VerificationNeededView: View {
        // MARK: Internal

        let account: Account
        @State
        var shouldRefreshAccount: () -> ()

        var body: some View {
            Button {
                status = .progressing
                popVerificationWebSheet()
            } label: {
                Text("account.test.verify.button")
            }
            .onAppear {
                popVerificationWebSheet()
            }
            .sheet(item: $sheetItem, content: { item in
                switch item {
                case let .gotVerification(verification):
                    NavigationStack {
                        GeetestValidateView(
                            challenge: verification.challenge,
                            gt: verification.gt,
                            completion: { validate in
                                status = .pending
                                verifyValidate(challenge: verification.challenge, validate: validate)
                                sheetItem = nil
                            }
                        )
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("sys.cancel") {
                                    sheetItem = nil
                                }
                            }
                        }
                        .navigationTitle("account.test.verify.web_sheet.title")
                    }
                }
            })
            if case let .fail(error) = status {
                Text("Error: \(error.localizedDescription)")
            }
        }

        func popVerificationWebSheet() {
            Task(priority: .userInitiated) {
                do {
                    let verification = try await MiHoYoAPI.createVerification(
                        cookie: account.safeCookie,
                        deviceFingerPrint: account.deviceFingerPrint,
                        challengePath: "https://api-takumi-record.mihoyo.com/game_record/app/genshin/api/dailyNote",
                        deviceId: account.safeUuid
                    )
                    status = .gotVerification(verification)
                    sheetItem = .gotVerification(verification)
                } catch {
                    status = .fail(error)
                }
            }
        }

        func verifyValidate(challenge: String, validate: String) {
            Task {
                do {
                    _ = try await MiHoYoAPI.verifyVerification(
                        challenge: challenge,
                        validate: validate,
                        challengePath: "https://api-takumi-record.mihoyo.com/game_record/app/genshin/api/dailyNote",
                        cookie: account.safeCookie,
                        deviceFingerPrint: account.deviceFingerPrint, deviceId: account.safeUuid
                    )
                    withAnimation {
                        shouldRefreshAccount()
                    }
                } catch {
                    status = .fail(error)
                }
            }
        }

        // MARK: Private

        private enum Status: CustomStringConvertible {
            case pending
            case progressing
            case gotVerification(Verification)
            case fail(Error)

            // MARK: Internal

            var description: String {
                switch self {
                case let .fail(error):
                    return "ERROR: \(error.localizedDescription)"
                case .progressing:
                    return "gettingVerification"
                case let .gotVerification(verification):
                    return "Challenge: \(verification.challenge)"
                case .pending:
                    return "PENDING"
                }
            }
        }

        private enum SheetItem: Identifiable {
            case gotVerification(Verification)

            // MARK: Internal

            var id: Int {
                switch self {
                case let .gotVerification(verification):
                    return verification.challenge.hashValue
                }
            }
        }

        @State
        private var status: Status = .progressing

        @State
        private var sheetItem: SheetItem?
    }

    @State
    private var status: TestStatus = .pending

    @State
    private var verificationErrorHasOccurred: Bool = false
}
