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
                let baseStr: String
                switch region {
                case .cn:
                    baseStr = "https://api-takumi-record.mihoyo.com/"
                case .global:
                    // TODO: 国际服改baseURL
                    baseStr = "https://api-takumi-record.mihoyo.com/"
                }
                // 由前缀和后缀共同组成的url
                let url = URL(string: baseStr + urlStr)!
                // 初始化请求
                var request = URLRequest(url: url)
                // 将请求数据类型设置为 application/json
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                // 添加token
                let token = UserDefaults.standard.string(forKey: "token")
                request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
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
