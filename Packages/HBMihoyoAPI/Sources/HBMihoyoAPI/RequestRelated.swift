//
//  RequestRelated.swift
//
//
//  Created by Bill Haku on 2023/3/25.
//

import Foundation
import HoYoKit

public typealias FetchResult = Result<UserData, FetchError>
public typealias BasicInfoFetchResult = Result<BasicInfos, FetchError>
public typealias CurrentEventsFetchResult = Result<CurrentEvent, FetchError>
public typealias LedgerDataFetchResult = Result<LedgerData, FetchError>
public typealias AllAvatarDetailFetchResult = Result<
    CharacterInventoryModel,
    FetchError
>

#if !os(watchOS)
//    typealias PlayerDetail.FetchResult = Result<
//        EnkaGI.PlayerDetailFetchModel,
//        RequestError
//    >
//    typealias PlayerDetail.FetchedResult = Result<
//        PlayerDetail,
//        PlayerDetail.Exceptions
//    >
public typealias SpiralAbyssDetailFetchResult = Result<
    SpiralAbyssDetail,
    FetchError
>
#endif

private let isMac: Bool = {
    #if os(OSX)
    return true
    #elseif os(watchOS)
    return false
    #elseif os(tvOS)
    return false
    #elseif os(iOS)
    #if targetEnvironment(macCatalyst)
    return true
    #else
    return false
    #endif
    #endif
}()

extension FetchResult {
    public static let defaultFetchResult: FetchResult = .success(
        UserData
            .defaultData
    )
}

// MARK: - RequestResult

public struct RequestResult: Codable {
    let data: FetchData?
    let message: String
    let retcode: Int
}

// MARK: - WidgetRequestResult

public struct WidgetRequestResult: Codable {
    let data: WidgetUserData?
    let message: String
    let retcode: Int
}

// MARK: - BasicInfoRequestResult

public struct BasicInfoRequestResult: Codable {
    let data: BasicInfos?
    let message: String
    let retcode: Int
}

// MARK: - LedgerDataRequestResult

public struct LedgerDataRequestResult: Codable {
    let data: LedgerData?
    let message: String
    let retcode: Int
}

// MARK: - AllAvatarDetailRequestDetail

public struct AllAvatarDetailRequestDetail: Codable {
    let data: CharacterInventoryModel?
    let message: String
    let retcode: Int
}

#if !os(watchOS)
public struct SpiralAbyssDetailRequestResult: Codable {
    let data: SpiralAbyssDetail?
    let message: String
    let retcode: Int
}
#endif

// MARK: - RequestError

public enum RequestError: Error {
    case dataTaskError(String)
    case noResponseData
    case responseError
    case decodeError(String)
    case errorWithCode(Int)
}

// MARK: - ErrorCode

public struct ErrorCode: Codable {
    var code: Int
    var message: String?
}

// MARK: - FetchError

public enum FetchError: Error, Equatable {
    case noFetchInfo

    case cookieInvalid(Int, String) // 10001
    case unmachedAccountCookie(Int, String) // 10103, 10104
    case accountInvalid(Int, String) // 1008
    case dataNotFound(Int, String) // -1, 10102

    case notLoginError(Int, String) // -100

    case decodeError(String)

    case requestError(RequestError)

    case unknownError(Int, String)

    case defaultStatus

    case accountUnbound

    case errorWithCode(Int)

    case accountAbnormal(Int) // 1034

    case noStoken

    // MARK: Public

    public static func == (lhs: FetchError, rhs: FetchError) -> Bool {
        lhs.description == rhs.description && lhs.message == rhs.message
    }
}

// MARK: - PSAServerError

public enum PSAServerError: Error {
    case uploadError(String)
    case getDataError(String)
}

extension FetchError {
    public var description: String {
        switch self {
        case .defaultStatus:
            return "error.refresh".localized
        case .noFetchInfo:
            return (isMac ? "error.selectAccount.mac" : "error.selectAccount.ios").localized
        case let .cookieInvalid(retcode, _):
            return String(
                format: NSLocalizedString(
                    "error.cookieInvalid:%lld",
                    comment: "错误码%@：Cookie失效，请重新登录"
                ),
                retcode
            )
        case let .unmachedAccountCookie(retcode, _):
            return String(
                format: NSLocalizedString(
                    "error.uidNotMatch:%lld",
                    comment: "错误码%@：米游社账号与UID不匹配"
                ),
                retcode
            )
        case let .accountInvalid(retcode, _):
            return String(
                format: NSLocalizedString(
                    "error.uidError:%lld",
                    comment: "错误码%@：UID有误"
                ),
                retcode
            )
        case .dataNotFound:
            return "error.gotoHoyolab".localized
        case .decodeError:
            return "error.decodeError".localized
        case .requestError:
            return "error.networkError".localized
        case .notLoginError:
            return "未获取到登录信息，请重试".localized
        case let .unknownError(retcode, _):
            return String(
                format: NSLocalizedString("error.unknown:%lld", comment: "error.unknown:%lld"),
                retcode
            )
        case .accountAbnormal:
            return "requestRelated.accountStatusAbnormal.errorMessage".localized
        case .noStoken:
            return "settings.notification.note.relogin".localized
        default:
            return ""
        }
    }

    public var message: String {
        switch self {
        case .defaultStatus:
            return ""

        case .noFetchInfo:
            return ""
        case let .notLoginError(retcode, message):
            return "(\(retcode))" + message
        case .cookieInvalid:
            return ""
        case let .unmachedAccountCookie(_, message):
            return message
        case let .accountInvalid(_, message):
            return message
        case let .dataNotFound(retcode, message):
            return "(\(retcode))" + message
        case let .decodeError(message):
            return message
        case let .requestError(requestError):
            switch requestError {
            case let .dataTaskError(message):
                return "\(message)"
            case .noResponseData:
                return "error.noReturnBack".localized
            case .responseError:
                return "error.noResponse".localized
            default:
                return "error.unknown".localized
            }
        case .accountAbnormal:
            return "requestRelated.accountStatusAbnormal.promptForVerificationInApp".localized
        case let .unknownError(_, message):
            return message
        case .noStoken:
            return "settings.notification.note.relogin".localized
        default:
            return ""
        }
    }
}

// MARK: - MultiTokenResult

public struct MultiTokenResult: Codable {
    public let retcode: Int
    public let message: String
    public let data: MultiToken?
}

// MARK: - MultiToken

public struct MultiToken: Codable {
    public struct Item: Codable {
        public let name: String
        public let token: String
    }

    public var list: [Item]

    public var stoken: String {
        list.first { item in
            item.name == "stoken"
        }?.token ?? ""
    }

    public var ltoken: String {
        list.first { item in
            item.name == "ltoken"
        }?.token ?? ""
    }
}

// MARK: - RequestAccountListResult

public struct RequestAccountListResult: Decodable {
    public let retcode: Int
    public let message: String
    public let data: AccountListData?
}

// MARK: - AccountListData

public struct AccountListData: Decodable {
    public let list: [FetchedAccount]
}
