// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

extension Enka {
    typealias PFPDict = [String: [String: String]]
    private static let pfpDict: PFPDict = {
        try! JSONDecoder().decode(
            PFPDict.self,
            from: try! .init(contentsOf: Bundle.module.url(forResource: "pfps", withExtension: "json")!)
        )
    }()

    public static func queryProfilePictureURL(pfpID: String) -> URL? {
        guard let fileNameStem = pfpDict[pfpID]?["iconPath"] else { return nil }
        return URL(string: "https://enka.network/ui/\(fileNameStem).png")
    }
}
