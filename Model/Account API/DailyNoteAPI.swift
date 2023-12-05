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
        let dailyNote = try await MiHoYoAPI.dailyNote(
            server: server,
            uid: safeUid,
            cookie: safeCookie,
            deviceFingerPrint: safeDeviceFingerPrint,
            deviceId: safeUuid
        )

        #if !os(watchOS)
        UserNotificationCenter.shared.createAllNotification(for: safeName, with: dailyNote, uid: safeUid)

        if #available(iOS 16.1, *) {
            ResinRecoveryActivityController.shared.updateResinRecoveryTimerActivity(for: self, data: dailyNote)
        }
        #endif
        return dailyNote
    }
}
