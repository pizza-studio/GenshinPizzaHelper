//
//  GlobalDonateView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/27.
//

import SwiftUI

struct GlobalDonateView: View {
    @StateObject var storeManager: StoreManager
    
    var body: some View {
        List(storeManager.myProducts, id: \.self) { product in
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
                    Text("Buy for \(product.price) \(product.priceLocale)")
                }
                .foregroundColor(.blue)
            }
        }
    }
}
