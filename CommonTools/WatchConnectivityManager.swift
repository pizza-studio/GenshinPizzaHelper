//
//  WatchConnectivityManager.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2024/1/29.
//

import CoreData
import Foundation
import WatchConnectivity

// MARK: - NotificationMessage

struct NotificationMessage: Identifiable {
    let id = UUID()
    let text: String
}

// MARK: - WatchConnectivityManager

final class WatchConnectivityManager: NSObject, ObservableObject {
    // MARK: Lifecycle

    private override init() {
        super.init()

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: Internal

    static let shared = WatchConnectivityManager()

    @Published
    var notificationMessage: NotificationMessage?
    @Published
    var sharedAccounts = [AccountConfiguration]()

    func send(_ message: String) {
        print("Send message")
        guard WCSession.default.activationState == .activated else {
            return
        }
        #if !os(watchOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        #endif

        WCSession.default.sendMessage([kMessageKey: message], replyHandler: nil) { error in
            print("Cannot send message: \(String(describing: error))")
        }
    }

    func sendAccounts(_ account: AccountConfiguration, _ message: String) {
        print("Send account")
        guard WCSession.default.activationState == .activated else {
            return
        }
        #if !os(watchOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        #endif

        let accountDict = [
            "name": account.name!,
            "cookie": account.cookie!,
            "deviceFingerPrint": account.deviceFingerPrint ?? "",
            "priority": account.priority,
            "serverRawValue": account.serverRawValue!,
            "uid": account.uid!,
            kMessageKey: message,
        ] as [String: Any]

        WCSession.default.sendMessage(accountDict, replyHandler: nil) { error in
            print("Cannot send accounts: \(String(describing: error))")
        }
    }

    // MARK: Private

    private let kMessageKey = "message"
    private let kAccountKey = "account"
}

// MARK: WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let notificationText = message[kMessageKey] as? String {
            DispatchQueue.main.async { [weak self] in
                self?.notificationMessage = NotificationMessage(text: notificationText)
            }
        }
        print("Received accounts")
        let accountReceived = AccountConfiguration(context: AccountConfigurationModel.shared.container.viewContext)
        let accountReceivedDict = message
        if let cookie = accountReceivedDict["cookie"] as? String,
           let deviceFingerPrintInner = accountReceivedDict["deviceFingerPrint"] as? String,
           let name = accountReceivedDict["name"] as? String,
           let priority = accountReceivedDict["priority"] as? NSNumber,
           let serverRawValue = accountReceivedDict["serverRawValue"] as? String,
           let uid = accountReceivedDict["uid"] as? String {
            accountReceived.cookie = cookie
            accountReceived.deviceFingerPrint = deviceFingerPrintInner
            accountReceived.name = name
            accountReceived.priority = Int(truncating: priority)
            accountReceived.serverRawValue = serverRawValue
            accountReceived.uid = uid
            do {
                try accountReceived.managedObjectContext?.save()
            } catch {
                print("save account failed: \(error)")
            }
            DispatchQueue.main.async { [weak self] in
                self?.sharedAccounts.append(accountReceived)
            }
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    #if !os(watchOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
