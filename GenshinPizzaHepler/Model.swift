//
//  Model.swift
//  Genshin Resin Checker
//
//  Created by 戴藏龙 on 2022/7/12.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    typealias QueryResult = (isValid: Bool, retcode: Int, data: UserData?)
    
    @Published var result: QueryResult = (false, 1, nil)
    
    func get_data(uid: String, server_id: String, cookie: String) -> (isValid: Bool, retcode: Int, data: UserData?) {
        
        
        

        fetch(uid: uid, server_id: server_id, cookie: cookie) {
            if $0 == nil {
                self.result = (false, 1, nil)
            } else if $0!.retcode != 0 {
                self.result = (false, $0!.retcode, nil)
            } else {
                self.result = (true, $0!.retcode, $0!.data!)
            }
            
            
        }
        
        return result
    }



    func fetch(uid: String, server_id: String, cookie: String, completion: @escaping ((RequestResult?) -> Void)) {
        
        func get_ds_token(uid: String, server_id: String) -> String {
            let s = "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs"
            let t = String(Int(Date().timeIntervalSince1970))
            let r = String(Int.random(in: 100000..<200000))
            let q = "role_id=\(uid)&server=\(server_id)"
            let c = "salt=\(s)&t=\(t)&r=\(r)&b=&q=\(q)".md5
            return t + "," + r + "," + c
        }

        var url = URLComponents(string: "https://api-takumi-record.mihoyo.com/game_record/app/genshin/api/dailyNote")!
        url.queryItems = [
            URLQueryItem(name: "server", value: server_id),
            URLQueryItem(name: "role_id", value: uid)
        ]

        var request = URLRequest(url: url.url!)
        request.allHTTPHeaderFields = [
            "DS": get_ds_token(uid: uid, server_id: server_id),
            "x-rpc-app_version": "2.11.1",
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.11.1",
            "x-rpc-client_type": "5",
            "Referer": "https://webstatic.mihoyo.com/",
            "Cookie": cookie
        ]

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
            
                let requestResult = try? decoder.decode(RequestResult.self, from: data)
                completion(requestResult)
                let dictionary = try? JSONSerialization.jsonObject(with: data)
                print(dictionary ?? "None")
                
            }
        }.resume()

    }
    
    
}


// MODEL START

struct RequestResult: Codable {
    
    let data: UserData?
    let message: String
    let retcode: Int
}

struct RecoveryTime: Codable {
    let day: Int
    let hour: Int
    let minute: Int
    let second: Int
    
    var secondDelta: Int {
        let hr = self.day * 24 + self.hour
        let min = hr * 60 + self.minute
        let sec = min * 60 + self.second
        return sec
    }
    
    enum CodingKeys: String, CodingKey {
        case day = "Day"
        case hour = "Hour"
        case minute = "Minute"
        case second = "Second"
    }
}

struct TransformerData: Codable {
    let recoveryTime: RecoveryTime
}

struct Expedition: Codable {
    let avatarSideIcon: String
    
    let remainedTimeStr: String
    var remainedTime: Int {
        Int(remainedTimeStr)!
    }

    let statusStr: String
    var status: Status {
        Status(rawValue: statusStr)!
    }

    enum Status: String {
        case ongoing = "Ongoing"
        case completed = "Finished"
    }

    enum CodingKeys: String, CodingKey {
        case avatarSideIcon = "avatarSideIcon"
        case remainedTimeStr = "remainedTime"
        case statusStr = "status"
    }
}

extension Array where Element == Expedition {
    var currentOngoingTask: Int {
        self.filter { expedition in
            expedition.status == .ongoing
        }
        .count
    }
}

struct UserData: Codable {
    let currentResin: Int
    let currentHomeCoin: Int
    var currentExpeditionNum: Int {
        expeditions.currentOngoingTask
    }
    let finishedTaskNum: Int
    
    let transformer: TransformerData
    var transformerTimeSecondInt: Int {
        transformer.recoveryTime.secondDelta
    }
    
    let expeditions: [Expedition]
    
    let resinRecoveryTime: String
    var resinRecoveryHour: Float {
        (Float(resinRecoveryTime) ?? 0.0)/(60*60)
    }
    var resinRecoveryTimeInt: Int {
        Int(resinRecoveryTime)!
    }
}



// MODEL END

import CommonCrypto
public extension String {
    /* ################################################################## */
    /**
     - returns: the String, as an MD5 hash.
     */
    var md5: String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)

        let hash = NSMutableString()

        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }

        result.deallocate()
        return hash as String
    }
}
