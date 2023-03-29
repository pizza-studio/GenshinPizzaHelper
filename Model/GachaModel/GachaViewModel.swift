//
//  GachaViewModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import Foundation
import CoreData
import HBMihoyoAPI
import SwiftUI
import Combine

class GachaViewModel: ObservableObject {
    let manager = GachaModelManager.shared
    /// 不要直接使用：所有祈愿记录
    @Published var gachaItems: [GachaItem] {
        didSet {
            filterGachaItem()
        }
    }

    @Published var filter: GachaFilter = .init() {
        didSet {
            filterGachaItem()
        }
    }
    /// 祈愿记录和要多少抽才出
    @Published var filteredGachaItemsWithCount: [(GachaItem, count: Int)] = []

    static let shared: GachaViewModel = .init()

    private init() {
        gachaItems = manager.fetchAll()
        filter.uid = gachaItems.first?.uid
    }

    var sortedAndFilteredGachaItem: [GachaItem] {
        gachaItems.sorted { lhs, rhs in
            lhs.id > rhs.id
        }
        .filter { item in
            if let uid = filter.uid {
                return item.uid == uid
            } else {
                return true
            }
        }
        .filter { item in
            item.gachaType == filter.gachaType
        }
    }

    func filterGachaItem() {
        let filteredItems = sortedAndFilteredGachaItem
        let counts = filteredItems.map { item in
            item.rankType
        }.enumerated().map { index, rank in
            let theRestOfArray = filteredItems[(index+1)...]
            if let nextIndexInRest = theRestOfArray.firstIndex(where: { $0.rankType >= rank }) {
                return nextIndexInRest - index
            } else {
                return filteredItems.count - index - 1
            }
        }
        filteredGachaItemsWithCount = zip(filteredItems, counts).filter { item, _ in
            switch filter.rank {
            case .five:
                return item.rankType == .five
            case .fourAndFive:
                return [.five, .four].contains(item.rankType)
            case .threeAndFourAndFire:
                return true
            }
        }
    }

    func refetchGachaItems() {
        gachaItems = manager.fetchAll()
    }

    func allAvaliableAccountUID() -> [String] {
        [String].init(
            Set<String>(
                gachaItems.map { item in
                    item.uid
                }
            )
        )
    }

    func getGachaAndSaveFor(_ account: AccountConfiguration,
                            observer: GachaFetchProgressObserver,
                            completion: @escaping ( (Result<(), GetGachaError>) -> () )) {
        let group = DispatchGroup()
        group.enter()
        MihoyoAPI.getGachaLogAndSave(account: account, manager: manager, observer: observer) { result in
            switch result {
            case .success(_):
                group.leave()
            case .failure(let error):
                completion(.failure(error))
            }
        }
        group.notify(queue: .main) {
            self.refetchGachaItems()
            completion(.success(()))
        }
    }
}

struct GachaFilter {
    var uid: String?
    var gachaType: GachaType = .character
    var rank: Rank = .five

    enum Rank: Int, CaseIterable, Identifiable {
        case five
        case fourAndFive
        case threeAndFourAndFire
        var id: Int { self.rawValue }
    }
}

extension GachaFilter.Rank: CustomStringConvertible {
    var description: String {
        switch self {
        case .five:
            return "五星"
        case .fourAndFive:
            return "四星及五星"
        case .threeAndFourAndFire:
            return "所有记录"
        }
    }
}

public class GachaFetchProgressObserver: ObservableObject {
    @Published var page: Int = 0
    @Published var gachaType: _GachaType = .standard
    @Published var currentItems: [GachaItem_FM] = []
    @Published var newItemCount: Int = 0

    private var cancellable : AnyCancellable?

    func initialize() {
        withAnimation {
            page = 0
            gachaType = .standard
            currentItems = []
            newItemCount = 0
        }
    }

    func fetching(page: Int, gachaType: _GachaType) {
        DispatchQueue.main.async {
            withAnimation {
                self.page = page
                self.gachaType = gachaType
            }
        }
    }

    func got(_ items: [GachaItem_FM]) {
        self.cancellable = Publishers.Zip(
            items.publisher,
            Timer.publish(every: 0.015, on: .main, in: .default).autoconnect()
        )
        .map(\.0)
        .sink(receiveValue: { newItem in
            withAnimation {
                self.currentItems.append(newItem)
            }
        })
    }

    func saveNewItemSucceed() {
        DispatchQueue.main.async {
            withAnimation {
                self.newItemCount += 1
            }
        }
    }

    private init() {}

    static var shared: GachaFetchProgressObserver = .init()
}
