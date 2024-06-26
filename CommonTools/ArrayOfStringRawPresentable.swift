//
//  ArrayOfStringRawPresentable.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/11/22.
//

import Foundation

#if hasFeature(RetroactiveAttribute)
extension [String]: @retroactive RawRepresentable {}
#else
extension [String]: RawRepresentable {}
#endif

extension [String] {
    public typealias RawValue = String
    public var rawValue: RawValue {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self) {
            return String(data: data, encoding: .utf8)!
        } else {
            return String(
                data: try! encoder.encode([String]()),
                encoding: .utf8
            )!
        }
    }

    public init?(rawValue: RawValue) {
        let decoder = JSONDecoder()
        if let data = rawValue.data(using: .utf8),
           let result = try? decoder.decode([String].self, from: data) {
            self = result
        } else {
            self = []
        }
    }
}
