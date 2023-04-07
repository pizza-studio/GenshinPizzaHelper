//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/4/1.
//

import Foundation
import SwiftUI
import RustXcframework
import UserNotifications

func gotURL(url: RustStr) {
    let urlString = url.toString()

    let APP_GROUP_IDENTIFIER: String = "group.GenshinPizzaHelper"
    let storage = UserDefaults(suiteName: APP_GROUP_IDENTIFIER)!

    let MIMT_URL_STORAGE_KEY: String = "mimtURLArray"
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    if let arrayJsonString = storage.string(forKey: MIMT_URL_STORAGE_KEY),
        !arrayJsonString.isEmpty,
       var urlStringArray = try? decoder.decode([String].self, from: arrayJsonString.data(using: .utf8)!) {

        urlStringArray.append(urlString)
        let toSave = String(data: try! encoder.encode(urlStringArray), encoding: .utf8)
        storage.set(toSave, forKey: MIMT_URL_STORAGE_KEY)

    } else {
        let urlStringArray: [String] = [urlString]
        let toSave = String(data: try! encoder.encode(urlStringArray), encoding: .utf8)
        storage.set(toSave, forKey: MIMT_URL_STORAGE_KEY)
    }

    let content = UNMutableNotificationContent()
    content.title = contentTitle
    content.body = contentBody

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)

    let uuidString = UUID().uuidString

    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request)

}

fileprivate let contentTitle: String = {
    guard let firstLocale = Locale.current.languageCode else { return "" }
    switch firstLocale {
    case _ where (firstLocale.contains("zh-Hans") || firstLocale.contains("zh-CN")):
        return "成功获取到祈愿链接"
    case _ where (firstLocale.contains("zh-Hant") || firstLocale
        .contains("zh-TW") || firstLocale.contains("zh-HK")):
        return "成功獲取到祈願鏈接"
    case _ where firstLocale.prefix(2).description == "ja": // Japanese
        return "Successfully obtained the wish history URL"
    case _ where firstLocale.prefix(2).description == "fr": // French
        return "Successfully obtained the wish history URL"
    case _ where firstLocale.prefix(2).description == "ru": // Russian
        return "Successfully obtained the wish history URL"
    case _ where firstLocale.prefix(2).description == "vi": // Vietnamese
        return "Successfully obtained the wish history URL"
    default: // English
        return "Successfully obtained the wish history URL"
    }
}()

fileprivate let contentBody: String = {
    guard let firstLocale = Locale.current.languageCode else { return "" }
    switch firstLocale {
    case _ where (firstLocale.contains("zh-Hans") || firstLocale.contains("zh-CN")):
        return "请返回继续获取祈愿记录。"
    case _ where (firstLocale.contains("zh-Hant") || firstLocale
        .contains("zh-TW") || firstLocale.contains("zh-HK")):
        return "請返回繼續獲取祈願記錄。"
    case _ where firstLocale.prefix(2).description == "ja": // Japanese
        return "Please go back and continue obtaining the wish history records."
    case _ where firstLocale.prefix(2).description == "fr": // French
        return "Please go back and continue obtaining the wish history records."
    case _ where firstLocale.prefix(2).description == "ru": // Russian
        return "Please go back and continue obtaining the wish history records."
    case _ where firstLocale.prefix(2).description == "vi": // Vietnamese
        return "Please go back and continue obtaining the wish history records."
    default: // English
        return "Please go back and continue obtaining the wish history records."
    }
}()
