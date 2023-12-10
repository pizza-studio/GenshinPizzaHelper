//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - Region

/// The region of server.
/// `.china` uses miyoushe api and `.global` uses HoYoLAB api.
public enum Region: String, CaseIterable {
    // CNMainland servers
    case mainlandChina = "hk4e_cn"
    // Other servers
    case global = "hk4e_global"

    // MARK: Public

    public var teyvatInteractiveMapURL: URL? {
        switch self {
        case .mainlandChina:
            URL(string: "https://webstatic.mihoyo.com/ys/app/interactive-map/index.html")
        case .global:
            URL(string: "https://act.hoyolab.com/ys/app/interactive-map/index.html")
        }
    }
}

// MARK: Identifiable

extension Region: Identifiable {
    public var id: String {
        rawValue
    }
}
