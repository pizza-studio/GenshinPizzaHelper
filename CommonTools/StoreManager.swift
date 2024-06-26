//
//  StoreManager.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/27.
//  IAP处理工具

import Foundation
import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate,
    SKPaymentTransactionObserver {
    // MARK: Internal

    @Published
    var myProducts = [SKProduct]()
    @Published
    var transactionState: SKPaymentTransactionState?
    var request: SKProductsRequest!

    // As soon as we receive a response from App Store Connect, this function is called.
    func productsRequest(
        _ request: SKProductsRequest,
        didReceive response: SKProductsResponse
    ) {
        print("Did receive Store Kit response")

        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                Task.detached { @MainActor in
                    self.myProducts.append(fetchedProduct)
                    print("Appended \(fetchedProduct.productIdentifier)")
                }
            }
            Task.detached { @MainActor in
                self.myProducts = self.myProducts.sorted {
                    $0.price.decimalValue < $1.price.decimalValue
                }
                print("Appended sorted")
            }
        } else {
            print("Response products found empty")
        }

        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }

    func getProducts(productIDs: [String]) {
        print("Start requesting products …")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }

    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payment.")
        }
    }

    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        for transaction in transactions {
            // 因为这里无法事先预知 Transaction 的内容，所以不适合使用 SindreSorhus_Defaults。
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                UserDefaults.opSuite.setValue(
                    true,
                    forKey: transaction.payment.productIdentifier
                )
                queue.finishTransaction(transaction)
                transactionState = .purchased
            case .restored:
                UserDefaults.opSuite.setValue(
                    true,
                    forKey: transaction.payment.productIdentifier
                )
                queue.finishTransaction(transaction)
                transactionState = .restored
            case .deferred, .failed:
                print(
                    "Payment Queue Error: \(String(describing: transaction.error))"
                )
                queue.finishTransaction(transaction)
                transactionState = .failed
            default:
                queue.finishTransaction(transaction)
            }
        }
    }

    // MARK: Private

    private func sortArray(product1: SKProduct, product2: SKProduct) -> Bool {
        product1.price.decimalValue < product2.price.decimalValue
    }
}
