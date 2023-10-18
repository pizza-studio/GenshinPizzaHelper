//
//  AnyLocalizedError.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/10/18.
//

import Foundation

enum AnyLocalizedError: LocalizedError {
    case localizedError(LocalizedError)
    case otherError(Error)

    // MARK: Lifecycle

    init(_ error: Error) {
        if let error = error as? LocalizedError {
            self = .localizedError(error)
        } else {
            self = .otherError(error)
        }
    }

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case let .localizedError(localizedError):
            localizedError.errorDescription
        case let .otherError(error):
            error.localizedDescription
        }
    }
}
