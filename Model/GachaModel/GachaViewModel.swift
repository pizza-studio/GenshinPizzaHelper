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
                            completion: @escaping ( (Result<(), GetGachaError>) -> () )) {
        let group = DispatchGroup()
        group.enter()
        MihoyoAPI.getGachaLogAndSave(account: account, manager: manager) { result in
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
