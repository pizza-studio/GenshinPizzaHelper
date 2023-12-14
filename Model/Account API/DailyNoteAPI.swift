//
//  DailyNoteAPI.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/11/30.
//

import Foundation
import HoYoKit

extension AccountConfiguration {
    func dailyNote() async throws -> any DailyNote {
        if server.region == .mainlandChina, sTokenV2 == nil {
            sTokenV2 = try await MiHoYoAPI.sTokenV2(cookie: safeCookie)
        }

        let dailyNote = try await MiHoYoAPI.dailyNote(
            server: server,
            uid: safeUid,
            cookie: safeCookie,
            sTokenV2: sTokenV2,
            deviceFingerPrint: safeDeviceFingerPrint,
            deviceId: safeUuid
        )

        #if !os(watchOS)
        UserNotificationCenter.shared.createAllNotification(for: safeName, with: dailyNote, uid: safeUid)
        #endif

        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            ResinRecoveryActivityController.shared.updateResinRecoveryTimerActivity(for: self, data: dailyNote)
        }
        #endif
        return dailyNote
    }
}
