//
//  GachaViewModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import Combine
import CoreData
import Foundation
import HBMihoyoAPI
import HoYoKit
import SwiftUI

// MARK: - GachaViewModel

class GachaViewModel: ObservableObject {
    // MARK: Lifecycle

    private init() {
//        self.gachaItems = []
        self.filter = .init()
        let uids = manager.allAvaliableUID()
        if !uids.isEmpty {
            filter.uid = uids.first!
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getRemoteChange),
            name: .NSPersistentStoreRemoteChange,
            object: manager
                .persistentStoreCoordinator
        )
        _ = manager.cleanDuplicatedItems()
        manager.viewModel = self
    }

    // MARK: Internal

    static let shared: GachaViewModel = .init()

    let manager = GachaModelManager.shared
    /// 祈愿记录和要多少抽才出
    @Published
    var filteredGachaItemsWithCount: [(GachaItem, count: Int)] = []

    @Published
    var allAvaliableAccountUID: [String] = []

//    {
//        didSet {
//            filterGachaItem()
//        }
//    }

    @Published
    var filter: GachaFilter {
        didSet {
            refetchGachaItems()
            filterGachaItem()
        }
    }

    var sortedAndFilteredGachaItem: [GachaItem] {
        if let uid = filter.uid {
            return manager.fetchAll(uid: uid, gachaType: filter.gachaType)
        } else {
            return []
        }
    }

    /// 当前filter对应uid的祈愿记录
//    @Published
    var gachaItems: [GachaItem] {
        if let uid = filter.uid {
            return manager.fetchAll(uid: uid)
        } else {
            return []
        }
    }

    func filterGachaItem() {
        let filteredItems = sortedAndFilteredGachaItem
        let counts = filteredItems.map { item in
            item.rankType
        }.enumerated().map { index, rank in
            let theRestOfArray = filteredItems[(index + 1)...]
            if let nextIndexInRest = theRestOfArray
                .firstIndex(where: { $0.rankType >= rank }) {
                return nextIndexInRest - index
            } else {
                return filteredItems.count - index
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.filteredGachaItemsWithCount = zip(filteredItems, counts)
                    .filter { item, _ in
                        switch self.filter.rank {
                        case .five:
                            return item.rankType == .five
                        case .fourAndFive:
                            return [.five, .four].contains(item.rankType)
                        case .threeAndFourAndFive:
                            return true
                        }
                    }
            }
        }
    }

    @objc
    func getRemoteChange() {
        print("GOT REMOTE CHANGE")
        refetchGachaItems()
    }

    func refetchGachaItems() {
        Task.detached { @MainActor in
            withAnimation {
                self.refreshAllAvaliableAccountUID()
                if (
                    self.filter
                        .uid ==
                        nil
                ) || !self.allAvaliableAccountUID.contains(self.filter.uid ?? "UID_NULL") {
                    self.filter.uid = self.allAvaliableAccountUID.first
                }
                self.objectWillChange.send()
            }
        }
    }

    func refreshAllAvaliableAccountUID() {
        allAvaliableAccountUID = manager.allAvaliableUID()
    }

    func getGachaAndSaveFor(
        _ account: AccountConfiguration,
        observer: GachaFetchProgressObserver,
        completion: @escaping (
            (Result<(), GetGachaError>)
                -> ()
        )
    ) {
        let group = DispatchGroup()
        group.enter()
        MihoyoAPI.getGachaLogAndSave(
            account: account,
            manager: manager,
            observer: observer
        ) { result in
            switch result {
            case .success:
                group.leave()
            case let .failure(error):
                completion(.failure(error))
            }
        }
        group.notify(queue: .main) {
            self.refetchGachaItems()
            completion(.success(()))
        }
    }

    func getGachaAndSaveFor(
        server: Server,
        authkey: GenAuthKeyResult.GenAuthKeyData,
        observer: GachaFetchProgressObserver,
        completion: @escaping (
            (Result<(), GetGachaError>) -> ()
        )
    ) {
        let group = DispatchGroup()
        group.enter()
        MihoyoAPI.getGachaLogAndSave(
            server: server,
            authKey: authkey,
            manager: manager,
            observer: observer
        ) { result in
            switch result {
            case .success:
                group.leave()
            case let .failure(error):
                completion(.failure(error))
            }
        }
        group.notify(queue: .main) {
            self.refetchGachaItems()
            completion(.success(()))
        }
    }

    func importGachaFromUIGFJson(
        uigfJson: UIGFv4
    )
        -> (uid: String, totalCount: Int, newCount: Int) {
        let profiles = uigfJson.giProfiles?.compactMap { $0 }
        var theUIDs = [String]()
        var (x, y, z) = ("", 0, 0)
        profiles?.forEach { theProfile in
            let items = theProfile.list
            let newCount = manager.addRecordItems(
                items,
                uid: theProfile.uid,
                profile: theProfile
            )
            y += items.count
            z += newCount
            theUIDs.append(theProfile.uid)
        }
        x = theUIDs.joined(separator: ", ")
        refetchGachaItems()
        return (x, y, z)
    }
}

// MARK: - GachaFilter

struct GachaFilter {
    enum Rank: Int, CaseIterable, Identifiable {
        case five = 5
        case fourAndFive = 4
        case threeAndFourAndFive = 3

        // MARK: Internal

        var id: Int { rawValue }
    }

    var uid: String?
    var gachaType: GachaType = .character
    var rank: Rank = .five
}

// MARK: - GachaFilter.Rank + CustomStringConvertible

extension GachaFilter.Rank: CustomStringConvertible {
    var description: String {
        switch self {
        case .five:
            return "app.gacha.record.5star".localized
        case .fourAndFive:
            return "app.gacha.record.4&5star".localized
        case .threeAndFourAndFive:
            return "app.gacha.record.all".localized
        }
    }
}

// MARK: - GachaFetchProgressObserver

public class GachaFetchProgressObserver: ObservableObject {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static var shared: GachaFetchProgressObserver = .init()

    @Published
    var page: Int = 0
    @Published
    var gachaType: MihoyoGachaType = .standard
    @Published
    var currentItems: [GachaItemFetched] = []
    @Published
    var newItemCount: Int = 0
    @Published
    var gachaTypeDateCounts: [GachaTypeDateCount] = []
    var shouldCancel: Bool = false

    func initialize() {
        withAnimation {
            page = 0
            gachaType = .standard
            currentItems = []
            newItemCount = 0
            gachaTypeDateCounts = []
            shouldCancel = false
        }
    }

    func fetching(page: Int, gachaType: MihoyoGachaType) {
        Task.detached { @MainActor in
            withAnimation {
                self.page = page
                self.gachaType = gachaType
            }
        }
    }

    func got(_ items: [GachaItemFetched]) {
        cancellables.append(
            Publishers.Zip(
                items.publisher,
                Timer.publish(
                    every: MihoyoAPI.GET_GACHA_DELAY_RANDOM_RANGE
                        .lowerBound / 20.0,
                    on: .main,
                    in: .default
                )
                .autoconnect()
            )
            .map(\.0)
            .sink(receiveValue: { newItem in
                withAnimation {
                    self.currentItems.append(newItem)
                    self.updateGachaItemCount(item: newItem)
                }
            })
        )
//        self.currentItems.append(contentsOf: items)
    }

    func updateGachaItemCount(item: GachaItemFetched) {
        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = item.time
        let type = GachaType.from(item.gachaType)
        let filteredGTDC: [GachaTypeDateCount] = gachaTypeDateCounts.filter {
            ($0.date == date) && ($0.type == type)
        }
        if filteredGTDC.isEmpty {
            let filteredFM: [GachaItemFetched] = currentItems.filter {
                ($0.time <= date) && (GachaType.from($0.gachaType) == type)
            }
            let count = GachaTypeDateCount(
                date: date,
                count: filteredFM.count,
                type: .from(item.gachaType)
            )
            gachaTypeDateCounts.append(count)
        }
        gachaTypeDateCounts.allIndices { element in
            (element.date >= date) && (element.type == type)
        }.forEach { index in
            self.gachaTypeDateCounts[index].count += 1
        }
    }

    func saveNewItemSucceed() {
        Task.detached { @MainActor in
            withAnimation {
                self.newItemCount += 1
            }
        }
    }

    // MARK: Private

    private var cancellables: [AnyCancellable] = []
}

extension Array where Element: Equatable {
    func allIndices(where predicate: (Self.Element) -> Bool) -> [Self.Index] {
        enumerated().filter { _, element in
            predicate(element)
        }.map { index, _ in
            index
        }
    }
}

// MARK: - GachaTypeDateCount

struct GachaTypeDateCount: Hashable, Identifiable {
    let date: Date
    var count: Int
    let type: GachaType

    var id: Int {
        hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(type)
    }
}
