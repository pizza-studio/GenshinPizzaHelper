//
//  GlobalDonateView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/27.
//  捐赠View

import SwiftUI
import StoreKit

struct GlobalDonateView: View {
    @StateObject var storeManager: StoreManager
    let locale = Locale.current
    @State private var isWechatAlipayShow: Bool = Locale.current.identifier == "zh_CN"
    let is_zh_CN: Bool = Locale.current.identifier == "zh_CN"
    var body: some View {
        List {
            Section {
                Text("请注意，以下内容为无偿捐赠，我们不会为您提供任何额外的服务。\n我们承诺，您对「原神披萨小助手」的捐赠仅用于覆盖App开发过程中的直接成本，包括但不限于苹果开发者计划会员资格的年费等。超出这部分成本的捐赠金额将悉数再次捐出。感谢您对我们的支持。")
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
            }
            if is_zh_CN {
                Section(footer: isWechatAlipayShow ? Text("您可以长按保存图片到对应App中扫描") : nil) {
                    Button("通过微信或支付宝支付") {
                        withAnimation() {
                            isWechatAlipayShow.toggle()
                        }
                    }
                    if isWechatAlipayShow {
                        HStack {
                            Image("WechatDonateQRCode")
                                .resizable()
                                .frame(maxHeight: 300)
                                .aspectRatio(contentMode: .fit)
                            Image("AlipayDonateQRCode")
                                .resizable()
                                .frame(maxHeight: 300)
                                .aspectRatio(contentMode: .fit)
                        }
                        .contextMenu {
                            Button("保存微信支付图片".localized) {
                                let uiImage = UIImage(named: "WechatDonateQRCode")
                                UIImageWriteToSavedPhotosAlbum(uiImage!, nil, nil, nil)
                            }
                            Button("保存支付宝图片".localized) {
                                let uiImage = UIImage(named: "AlipayDonateQRCode")
                                UIImageWriteToSavedPhotosAlbum(uiImage!, nil, nil, nil)
                            }
                        }
                    }
                }
            }

            Section(header: Text("捐赠项目")) {
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
                        Button("支付") {
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

//            if !is_zh_CN {
//                  Foreign region do not show wechat pay and alipay
//            }
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


