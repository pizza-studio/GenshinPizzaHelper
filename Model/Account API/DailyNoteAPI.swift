//
//  DailyNoteAPI.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/11/30.
//

import Defaults
import Foundation
import HoYoKit

extension Account {
    func dailyNote() async throws -> any DailyNote {
        let dailyNote = try await MiHoYoAPI.dailyNote(
            server: server,
            uid: safeUid,
            cookie: safeCookie,
            deviceFingerPrint: safeDeviceFingerPrint,
            deviceId: safeUuid
        )

        #if !os(watchOS)
        UserNotificationCenter.shared.createAllNotification(for: safeName, with: dailyNote, uid: safeUid)
        #endif

        #if canImport(ActivityKit)
        if #available(iOS 16.1, *), Defaults[.autoUpdateResinRecoveryTimerUsingReFetchData] {
            ResinRecoveryActivityController.shared.updateResinRecoveryTimerActivity(for: self, data: dailyNote)
        }
        #endif
        return dailyNote
    }
}
