//
//  GIDictionary.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/7/30.
//

import Foundation

// MARK: - GIDictionaryAPI

enum GIDictionaryAPI {}

extension GIDictionaryAPI {
    static func translation(query: String, page: Int, pageSize: Int) async throws -> GIDictionaryTranslationResult {
        var components = URLComponents()

        components.scheme = "https"

        components.host = "gidict-api.pizzastudio.org"

        components.path = "/v1/translations/\(query)"

        components.queryItems = [.init(name: "page", value: "\(page)"), .init(name: "page_size", value: "\(pageSize)")]

        let url = components.url!

        let request = URLRequest(url: url)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try JSONDecoder().decode(GIDictionaryTranslationResult.self, from: data)
    }
}
