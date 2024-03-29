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
    case enkaJSONGitCN = "https://gitcode.net/SHIKISUEN/Enka-API-docs/-/raw/master/"
    case enkaJSONGitGlobal = "https://raw.githubusercontent.com/EnkaNetwork/API-docs/master/"

    // MARK: Public

    public var hostBase: String { rawValue }
}
