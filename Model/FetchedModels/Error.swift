//
//  Error.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

enum RequestError: Error {
    case dataTaskError(String)
    case noResponseData
    case responseError
    case decodeError(String)
}

struct ErrorCode: Codable {
    var code: Int
    var message: String?
}



enum FetchError: Error {
    case noFetchInfo
    
    case cookieInvalid(Int, String) // 10001
    case unmachedAccountCookie(Int, String) // 10102, 10103, 10104
    case accountInvalid(Int, String) // 1008
    case dataNotFound(Int, String) // -1
    
    case decodeError(String)
    
    case requestError(RequestError)
    
    case unknownError(Int, String)
    
    case defaultStatus
    
    case accountUnbound 
}

extension FetchError {
    var description: String {
        switch self {
        case .defaultStatus:
            return "请先刷新以获取树脂状态"
            
        case .noFetchInfo:
            return "请长按小组件选择账号"
            
        case .cookieInvalid(let retcode, _):
            return "错误码\(retcode)：Cookie失效，请重新登录"
        case .unmachedAccountCookie(let retcode, _):
            return "错误码\(retcode)：米游社账号与UID不匹配"
        case .accountInvalid(let retcode, _):
            return "错误码\(retcode)：UID有误"
        case .dataNotFound(let retcode, _):
            return "错误码\(retcode)：数据未找到"
        case .decodeError( _):
            return "解码错误"
        case .requestError( _):
            return "网络错误"
        case .unknownError(let retcode, _):
            return "未知错误码：\(retcode)"
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
        case .cookieInvalid(_, _):
            return ""
        case .unmachedAccountCookie(_, let message):
            return message
        case .accountInvalid(_, let message):
            return message
        case .dataNotFound(_, let message):
            return message
        case .decodeError(let message):
            return message
        case .requestError(let requestError):
            switch requestError {
            case .dataTaskError(let message):
                return "\(message)"
            case .noResponseData:
                return "无返回数据"
            case .responseError:
                return "无响应"
            default:
                return "未知错误"
            }
        case .unknownError(_, let message):
            return message
        default:
            return ""
        }
    
    }
}


