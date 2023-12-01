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
        return dailyNote
    }
}
