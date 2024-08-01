// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import Foundation
import HBMihoyoAPI

// MARK: - HostType

public enum HostType: String {
    case generalHost = "https://gi.pizzastudio.org/"
    case artifactRatingHost = "https://artifact-rating.pizzastudio.org/"
    case abyssHost = "http://81.70.76.222/"
    case enkaJSONGitCN = """
    https://gitlink.org.cn/attachments/entries/get_file?download_url=https://www.gitlink.org.cn/api/ShikiSuen/Enka-API-docs/raw/
    """
    case enkaJSONGitGlobal = "https://raw.githubusercontent.com/EnkaNetwork/API-docs/master/"

    // MARK: Public

    public var hostBase: String { rawValue }

    public var hostSuffix: String {
        switch self {
        case .enkaJSONGitCN: return "?ref=master"
        default: return ""
        }
    }
}
