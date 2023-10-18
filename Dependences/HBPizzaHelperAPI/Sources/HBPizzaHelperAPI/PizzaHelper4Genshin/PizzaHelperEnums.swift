//
//  PizzaHelperEnums.swift
//
//
//  Created by ShikiSuen on 2023/10/8.
//

import Defaults
import Foundation
import HBMihoyoAPI
import HoYoKit

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
