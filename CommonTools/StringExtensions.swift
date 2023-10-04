//
//  StringExtensions.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/25.
//  Strings 功能扩充。

import Foundation

extension String {
    /// 返回一个无参数String的本地化值。
    var localized: String {
        String(format: NSLocalizedString(self, comment: ""))
    }

    public func i18n(_ identifier: String? = nil) -> String {
        let identifier = identifier ?? Bundle.main.preferredLocalizations.first
        let path = Bundle.main.path(forResource: identifier, ofType: "lproj")
        guard let path = path, let bundle = Bundle(path: path) else {
            return localized
        }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }

    /// 检测是否包含汉字或假名。
    /// Remark: 暂无全形标点检测之功能。
    var containsKanjiOrKana: Bool {
        range(of: #"\p{Script=Han}|\p{Script=Katakana}|\p{Script=Hiragana}"#, options: .regularExpression) != nil
    }
}
