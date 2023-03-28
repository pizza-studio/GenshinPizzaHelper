//
//  GachaViewModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import CoreData
import Foundation
import HBMihoyoAPI

class GachaViewModel: ObservableObject {
    // MARK: Lifecycle

    private init() {
        self.gachaItems = manager.fetchAll()
    }

    // MARK: Internal

    static let shared: GachaViewModel = .init()

    let manager = GachaModelManager.shared

    @Published
    var gachaItems: [GachaItem]

    func refetchGachaItems() {
        gachaItems = manager.fetchAll()
    }

    func allAvaliableAccountUID() -> [String] {
        gachaItems.map { $0.uid }
    }

    func getGachaAndSaveFor(
        _ account: AccountConfiguration,
        completion: @escaping (
            (Result<(), GetGachaError>)
                -> ()
        )
    ) {
        let group = DispatchGroup()
        group.enter()
        MihoyoAPI
            .getGachaLogAndSave(account: account, manager: manager) { result in
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
}
