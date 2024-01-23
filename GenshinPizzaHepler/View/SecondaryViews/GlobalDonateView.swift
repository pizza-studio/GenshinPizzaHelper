//
//  GlobalDonateView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/27.
//  捐赠View

import StoreKit
import SwiftUI

struct GlobalDonateView: View {
    // MARK: Internal

    @StateObject
    var storeManager: StoreManager
    let locale = Locale.current

    var body: some View {
        List {
            Section {
                Text("donate.msg")
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
            }
            Section {
                NavigationLink(
                    destination: WebBrowserView(
                        url: "https://gi.pizzastudio.org/static/thanks.html"
                    )
                    .navigationTitle("donate.specialThanks")
                ) {
                    Text("donate.specialThanks")
                }
            }

            Section(header: Text("donate.item.header")) {
                if storeManager.myProducts.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
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
                        Button("donate.item.pay") {
                            storeManager.purchaseProduct(product: product)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
        .navigationTitle("settings.misc.supportUs")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    private func priceLocalized(product: SKProduct) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: product.price) ?? "Price Error"
    }
}
