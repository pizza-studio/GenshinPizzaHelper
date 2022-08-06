//
//  HttpMethod.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

enum Method {
    case post
    case get
    case put
}

enum Region {
    case cn
    case global
}

struct HttpMethod<T: Codable> {

    /// 综合的http post方法接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - urlStr:String，url的字符串后缀，即request的类型
    ///   - httpBody:String，包含所有请求参数
    ///   - completion:异步返回处理好的data以及报错的类型
    static func commonRequest (
        _ method: Method,
        _ urlStr: String,
        _ region: Region,
        _ serverID: String,
        _ uid: String,
        _ cookie: String,
        completion: @escaping(
            _ dataProcessed: T,
            _ errorType: String?
        ) -> ()
    ) {
        let networkReachability = NetworkReachability()

        func get_ds_token(uid: String, server_id: String) -> String {
            let s: String
            switch region {
            case .cn:
                s = "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs"
            case .global:
                s = "okr4obncj8bw5a65hbnn5oo6ixjc3l9w"
            }
            let t = String(Int(Date().timeIntervalSince1970))
            let r = String(Int.random(in: 100000..<200000))
            let q = "role_id=\(uid)&server=\(server_id)"
            let c = "salt=\(s)&t=\(t)&r=\(r)&b=&q=\(q)".md5
            return t + "," + r + "," + c
        }

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {

                // 请求url前缀，后跟request的类型
                let baseStr: String
                let appVersion: String
                let userAgent: String
                let clientType: String
                switch region {
                case .cn:
                    baseStr = "https://api-takumi-record.mihoyo.com/"
                    appVersion = "2.11.1"
                    userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.11.1"
                    clientType = "5"
                case .global:
                    // TODO: 国际服改Request Header
                    baseStr = "https://api-takumi-record.mihoyo.com/"
                    appVersion = "2.11.1"
                    userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.11.1"
                    clientType = "5"
                }
                // 由前缀和后缀共同组成的url
                var url = URLComponents(string: baseStr + urlStr)!
                url.queryItems = [
                    URLQueryItem(name: "server", value: serverID),
                    URLQueryItem(name: "role_id", value: uid)
                ]
                // 初始化请求
                var request = URLRequest(url: url.url!)
                // 将请求数据类型设置为 application/json
                request.allHTTPHeaderFields = [
                    "DS": get_ds_token(uid: uid, server_id: serverID),
                    "x-rpc-app_version": appVersion,
                    "User-Agent": userAgent,
                    "x-rpc-client_type": clientType,
                    "Referer": "https://webstatic.mihoyo.com/",
                    "Cookie": cookie
                ]
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                URLSession.shared.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        print(
                            "DataTask error in General HttpMethod: " +
                            error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            print("found response data nil")
                            return
                        }
                        guard let response = response as? HTTPURLResponse else {
                            print("response error")
                            return
                        }

                        if response.statusCode != 200 {
                            print("response error, code: \(response.statusCode)")
                        }
                        DispatchQueue.main.async {
                            // json转模型，这里用泛型
                            let errorCode = try? JSONDecoder().decode(ErrorCode.self, from: data)
                            print(data)
                            print(errorCode ?? "ErrorCode nil")
                            if errorCode?.code != 0 {
                                // 不建议强制解码 好几次app崩溃报错都是在这里
                                do {
                                    let dataProcessed = try JSONDecoder().decode(T.self, from: data)
                                    completion(dataProcessed, errorCode?.message)
                                } catch {
                                    print("errcode != 0, decode fail")
                                }
                            }
                            else if errorCode?.code == 0 {
                                do {
                                    let dataProcessed = try JSONDecoder().decode(T.self, from: data)
                                    print("errcode == 0, decode success")
                                    completion(dataProcessed, errorCode?.message)
                                } catch {
                                    print("errcode == 0, decode fail")
                                }
                            }
                        }
                    }
                }.resume()
            }
        }
    }

    /// 登录的http post方法接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - urlStr:String，url的字符串后缀，即request的类型
    ///   - bodyJson:String，包含所有请求参数
    ///   - completion:异步返回处理好的data以及报错的类型
    static func loginRequest (
        _ method: Method,
        _ urlStr: String,
        _ bodyJson: [String: Any],
        completion: @escaping(
            _ dataProcessed: T,
            _ errorType: String?
        ) -> ()
    ) {
        let networkReachability = NetworkReachability()

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {

                // 请求url前缀，后跟request的类型
                let baseStr = "https://cpes.legym.cn/"
                // 由前缀和后缀共同组成的url
                let url = URL(string: baseStr + urlStr)!
                // 初始化请求
                var request = URLRequest(url: url)
                // 将请求数据类型设置为 application/json
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 转成数据
                let jsonData = try? JSONSerialization.data(withJSONObject: bodyJson)
                request.httpBody = jsonData
                print("start request")
                // 开始请求
                URLSession.shared.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        print("DataTask error in Login HttpMethod: " + error.localizedDescription)
                    } else {
                        guard let data = data else {
                            print("found response data nil")
                            return
                        }
                        guard let response = response as? HTTPURLResponse else {
                            print("response error")
                            return
                        }

                        if response.statusCode != 200 {
                            print("response error, code: \(response.statusCode)")
                        }
                        DispatchQueue.main.async {
                            // json转模型，这里用泛型
                            let errorCode = try? JSONDecoder().decode(ErrorCode.self, from: data)
                            print(data)
                            print(errorCode ?? "ErrorCode nil")
                            if errorCode?.code != 0 {
                                // 不建议强制解码 好几次app崩溃报错都是在这里
                                do {
                                    let dataProcessed = try JSONDecoder().decode(T.self, from: data)
                                    completion(dataProcessed, errorCode?.message)
                                } catch {
                                    print("errcode != 0, decode fail")
                                }
                            }
                            else if errorCode?.code == 0 {
                                do {
                                    let dataProcessed = try JSONDecoder().decode(T.self, from: data)
                                    print("errcode == 0, decode success")
                                    completion(dataProcessed, errorCode?.message)
                                } catch {
                                    print("errcode == 0, decode fail")
                                }
                            }
                        }
                    }
                }.resume()
            }
        }
    }
}

class API {

}

// String的扩展，让其具有直接加键值对的功能
extension String {
    func addPara(_ key: String, _ value: String) -> String {
        var str = self
        if str != "" {
            str += "&"
        }
        str += "\(key)=\(value)"
        return str
    }
}
