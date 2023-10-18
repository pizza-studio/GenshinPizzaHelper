//
//  File.swift
//
//
//  Created by ShikiSuen on 2023/10/18.
//

import Defaults
import Foundation

// MARK: - EnkaSputnik

#if !os(watchOS)
public class EnkaSputnik: ObservableObject {
    // MARK: Lifecycle

    private init() {}

    // MARK: Public

    public typealias CharLoc = [String: String]
    public typealias CharMap = [String: ENCharacterMap.Character]

    public struct DataSet {
        public let charLoc: CharLoc
        public let charMap: CharMap
    }

    public static let shared = EnkaSputnik()

    @Published
    public var charLoc: CharLoc? = try? JSONDecoder().decode(ENCharacterLoc.self, from: Defaults[.enkaMapLoc])
        .getLocalizedDictionary() {
        didSet {
            Defaults[.lastEnkaDataCheckDate] = .init()
        }
    }

    @Published
    public var charMap: CharMap? = try? JSONDecoder()
        .decode(ENCharacterMap.self, from: Defaults[.enkaMapCharacters]).characterDetails {
        didSet {
            Defaults[.lastEnkaDataCheckDate] = .init()
        }
    }

    // MARK: Private

    private let gcdGroup = DispatchGroup()
}

// MARK: - Dynamic Variables

extension EnkaSputnik {
    public var enkaDataWrecked: Bool {
        charLoc == nil || charMap == nil || (charLoc?.count ?? 0) * (charMap?.count ?? 0) == 0
    }

    public var availableDataSet: DataSet? {
        guard let charLoc = charLoc, let charMap = charMap, !enkaDataWrecked else { return nil }
        return .init(charLoc: charLoc, charMap: charMap)
    }

    public var enkaDataNeedsUpdate: Bool {
        var performCheck = enkaDataWrecked
        if !performCheck, let expired = Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
           Defaults[.lastEnkaDataCheckDate] < expired {
            print("Enka data expired, triggering update.")
            performCheck = true
        } else if performCheck {
            print("Enka data (in local storage) corrupted, triggering update.")
        }
        return performCheck
    }
}

// MARK: - Data Updaters

extension EnkaSputnik {
    // 同步 Enka 资料，只是不用 Async。
    public func refreshCharLocAndCharMapSansAsync() {
        guard enkaDataNeedsUpdate else { return }
        PizzaHelperAPI.fetchENCharacterLocData(from: .mainlandCN) {
            Defaults[.enkaMapLoc] = try! JSONEncoder().encode($0)
            self.charLoc = $0.getLocalizedDictionary()
        } onFailure: {
            PizzaHelperAPI.fetchENCharacterLocData(from: .global) {
                Defaults[.enkaMapLoc] = try! JSONEncoder().encode($0)
                self.charLoc = $0.getLocalizedDictionary()
            }
        }
        PizzaHelperAPI.fetchENCharacterDetailData(from: .mainlandCN) {
            Defaults[.enkaMapCharacters] = try! JSONEncoder().encode($0)
            self.charMap = $0.characterDetails
        } onFailure: {
            PizzaHelperAPI.fetchENCharacterDetailData(from: .global) {
                Defaults[.enkaMapCharacters] = try! JSONEncoder().encode($0)
                self.charMap = $0.characterDetails
            }
        }
    }

    // 同步 Enka 资料，使用 GCD Async。
    public func refreshCharLocAndCharMapWithAsync(onFinish: @escaping (DataSet?) -> ()) {
        gcdGroup.enter()
        PizzaHelperAPI.fetchENCharacterLocData(from: .mainlandCN) {
            Defaults[.enkaMapLoc] = try! JSONEncoder().encode($0)
            self.charLoc = $0.getLocalizedDictionary()
            self.gcdGroup.leave()
        } onFailure: {
            PizzaHelperAPI.fetchENCharacterLocData(from: .global) {
                self.charLoc = $0.getLocalizedDictionary()
                self.gcdGroup.leave()
            }
        }
        gcdGroup.enter()
        PizzaHelperAPI.fetchENCharacterDetailData(from: .mainlandCN) {
            Defaults[.enkaMapCharacters] = try! JSONEncoder().encode($0)
            self.charMap = $0.characterDetails
            self.gcdGroup.leave()
        } onFailure: {
            PizzaHelperAPI.fetchENCharacterDetailData(from: .global) {
                Defaults[.enkaMapCharacters] = try! JSONEncoder().encode($0)
                self.charMap = $0.characterDetails
                self.gcdGroup.leave()
            }
        }
        gcdGroup.notify(queue: .main) {
            onFinish(self.availableDataSet)
        }
    }
}

// MARK: - Data Fixers

extension EnkaSputnik {
    // 检查本地 Enka 暂存资料是否损毁。如有损毁，则用 Bundle 内建的 JSON 重建之。
    public func attemptToFixLocalEnkaStorage() {
        guard enkaDataWrecked else { return }
        Defaults.reset(.enkaMapLoc)
        Defaults.reset(.enkaMapCharacters)
        charLoc = try? JSONDecoder()
            .decode(ENCharacterLoc.self, from: Defaults[.enkaMapLoc]).getLocalizedDictionary()
        charMap = try? JSONDecoder()
            .decode(ENCharacterMap.self, from: Defaults[.enkaMapCharacters]).characterDetails
        guard enkaDataWrecked else { return }
        // 本地 JSON 资料恢复了也没用。一般情况下不该出现这种情况。
        refreshCharLocAndCharMapSansAsync()
    }
}
#endif
