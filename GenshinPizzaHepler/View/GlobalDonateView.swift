//
//  GlobalDonateView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/27.
//

import SwiftUI
import StoreKit

struct GlobalDonateView: View {
    @StateObject var storeManager: StoreManager
    
    var body: some View {
        List {
            Section {
                Text("请注意，以下内容为无偿捐赠，我们不会为您提供任何额外的服务。我们承诺，您对「原神披萨小助手」的捐赠仅用于覆盖App开发过程中的直接成本，包括但不限于Apple Developer Program （苹果开发者计划）会员资格的年费等。超出这部分成本的捐赠金额将悉数再次捐出。感谢您对我们的支持。")
                    .padding()
            }
            Section(header: Text("捐赠项目")) {
                if storeManager.myProducts.isEmpty {
                    ProgressView()
                }
                ForEach(storeManager.myProducts, id: \.self) { product in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.localizedTitle)
                                .font(.headline)
                            Text(product.localizedDescription)
                                .font(.caption2)
                        }
                        Spacer()
                        Button(action: {
                            //Purchase particular ILO product
                            storeManager.purchaseProduct(product: product)
                        }) {
                            Text("支付")
                        }
                        .buttonStyle(BlueCapsuleButton())
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("支持我们")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func priceLocalized(product: SKProduct) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: product.price) ?? "Price Error"
    }
}

private struct BlueCapsuleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}
