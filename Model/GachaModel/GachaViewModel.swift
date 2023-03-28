//
//  GachaViewModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import Foundation
import CoreData
import HBMihoyoAPI

class GachaViewModel: ObservableObject {
    let manager = GachaModelManager.shared

    @Published var gachaItems: [GachaItem]

    static let shared: GachaViewModel = .init()

    private init() {
        gachaItems = manager.fetchAll()
    }

    func refetchGachaItems() {
        gachaItems = manager.fetchAll()
    }

    func allAvaliableAccountUID() -> [String] {
        gachaItems.map( { $0.uid } )
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

public class GachaFetchProgressObserver: ObservableObject {
    @Published var page: Int = 0
    @Published var gachaType: GachaType = .character
    @Published var currentItems: [GachaItem_FM]?

    func fetching(page: Int, gachaType: GachaType) {
        DispatchQueue.main.async {
            self.page = page
            self.gachaType = gachaType
        }
    }

    func got(_ items: [GachaItem_FM]) {
        DispatchQueue.main.async {
            self.currentItems = items
        }
    }

    private init() {}

    static var shared: GachaFetchProgressObserver = .init()
}
