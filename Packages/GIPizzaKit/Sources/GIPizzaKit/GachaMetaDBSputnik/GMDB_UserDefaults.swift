// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import Foundation
import GachaMetaDB

#if !os(watchOS)
extension UserDefaults {
    public static let gmdbSuite = UserDefaults(suiteName: "group.GenshinPizzaHelper.GachaMetaDB") ?? .opSuite
}

extension Defaults.Keys {
    public static let lastGMDBDataCheckDate = Key<Date>(
        "lastCheckDateForGachaMetaDB",
        default: .init(timeIntervalSince1970: 0),
        suite: .gmdbSuite
    )
    public static let localGachaMetaDB = Key<GachaMeta.MetaDB>(
        "localGachaMetaDB",
        default: try! GachaMeta.MetaDB.getBundledDefault(for: .genshinImpact)!,
        suite: .gmdbSuite
    )
    /// 反向查询专用资料库，供原披助手所特需。必须是简体中文。
    public static let localGachaMetaDBReversed = Key<[String: Int]>(
        "localGachaMetaDBReversed",
        default: {
            try! GachaMeta.MetaDB.getBundledDefault(for: .genshinImpact)!
                .generateHotReverseQueryDict(for: "zh-cn")!
        }(),
        suite: .gmdbSuite
    )
    /// 针对 UIGF v2.3 及之前版本的文件导入时所使用的垫底时区，预设值为 nil。
    public static let fallbackTimeForGIGFFileImport = Key<TimeZone?>(
        "fallbackTimeForGIGFFileImport",
        default: nil,
        suite: .gmdbSuite
    )
}

extension GachaItemMetadata: _DefaultsSerializable {}
extension TimeZone: _DefaultsSerializable {}

#endif
