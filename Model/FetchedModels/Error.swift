//
//  Error.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//  错误信息

import Foundation

// MARK: - RequestError

enum RequestError: Error {
    case dataTaskError(String)
    case noResponseData
    case responseError
    case decodeError(String)
    case errorWithCode(Int)
}

// MARK: - ErrorCode

struct ErrorCode: Codable {
    var code: Int
    var message: String?
}

// MARK: - FetchError

enum FetchError: Error, Equatable {
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

    // MARK: Internal

    static func == (lhs: FetchError, rhs: FetchError) -> Bool {
        lhs.description == rhs.description && lhs.message == rhs.message
    }
}

// MARK: - PSAServerError

enum PSAServerError: Error {
    case uploadError(String)
    case getDataError(String)
}

extension FetchError {
    var description: String {
        switch self {
        case .defaultStatus:
            return "请先刷新以获取树脂状态".localized

        case .noFetchInfo:
            return "请长按小组件选择帐号".localized

        case let .cookieInvalid(retcode, _):
            return String(
                format: NSLocalizedString(
                    "错误码%lld：Cookie失效，请重新登录",
                    comment: "错误码%@：Cookie失效，请重新登录"
                ),
                retcode
            )
        case let .unmachedAccountCookie(retcode, _):
            return String(
                format: NSLocalizedString(
                    "错误码%lld：米游社帐号与UID不匹配，请手动输入UID",
                    comment: "错误码%@：米游社帐号与UID不匹配"
                ),
                retcode
            )
        case let .accountInvalid(retcode, _):
            return String(
                format: NSLocalizedString(
                    "错误码%lld：UID有误",
                    comment: "错误码%@：UID有误"
                ),
                retcode
            )
        case .dataNotFound:
            return "请前往米游社（或Hoyolab）打开旅行便笺功能".localized
        case .decodeError:
            return "解码错误：请检查网络环境".localized
        case .requestError:
            return "网络错误".localized
        case .notLoginError:
            return "未获取到登录信息，请重试".localized
        case let .unknownError(retcode, _):
            return String(
                format: NSLocalizedString("未知错误码：%lld", comment: "未知错误码：%lld"),
                retcode
            )
        case .accountAbnormal:
            return "（1034）账号状态异常，建议降低小组件同步频率，或长按小组件开启简洁模式".localized
        case .noStoken:
            return "请重新登录本账号以获取stoken".localized
        default:
            return ""
        }
    }

    var message: String {
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
                return "无返回数据".localized
            case .responseError:
                return "无响应".localized
            default:
                return "未知错误".localized
            }
        case .accountAbnormal:
            return "（1034）账号状态异常，请前往「米游社」App-「我的」-「我的角色」进行验证".localized
        case let .unknownError(_, message):
            return message
        case .noStoken:
            return "请重新登录本账号以获取stoken".localized
        default:
            return ""
        }
    }
}
