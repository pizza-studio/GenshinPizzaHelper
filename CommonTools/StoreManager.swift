//
//  StoreManager.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/27.
//

import Foundation
import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate {
    @Published var myProducts = [SKProduct]()
    var request: SKProductsRequest!

    // As soon as we receive a response from App Store Connect, this function is called.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Did receive Store Kit response")

        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                }
            }
        }

        for invalidIdentifier in response.invalidProductIdentifiers {
                print("Invalid identifiers found: \(invalidIdentifier)")
            }
    }

    func getProducts(productIDs: [String]) {
        print("Start requesting products ...")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }
}
