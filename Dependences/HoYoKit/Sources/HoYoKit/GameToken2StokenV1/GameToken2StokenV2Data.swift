//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2024/5/12.
//

import Foundation

public struct GameToken2StokenV2Data: Decodable, DecodableFromMiHoYoAPIJSONResult {
    let stoken: String

    enum CodingKeys: String, CodingKey {
        case token = "token"
    }

    struct Token: Decodable {
        let token: String
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tokenData = try container.decode(Token.self, forKey: .token)
        self.stoken = tokenData.token
    }
}
