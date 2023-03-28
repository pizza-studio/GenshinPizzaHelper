//
//  GachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import HBMihoyoAPI
import SwiftUI

struct GachaView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    let gachaViewModel: GachaViewModel = .shared
    var body: some View {
        List {
            Section {
                NavigationLink("Get Gacha View") {
                    GetGachaView()
                }
            }
            Section {
                ForEach(gachaViewModel.gachaItems) { item in
                    VStack {
                        Text(item.name)
                        Text(item.id)
                    }
                }
            }
//            TestGenGachaKey()
        }
        .environmentObject(gachaViewModel)
    }
}

// struct TestGenGachaKey: View {
//    @EnvironmentObject
//    var viewModel: ViewModel
//    @State var url: String?
//    var body: some View {
//        Group {
//            Button("Get URL") {
//                MihoyoAPI.genAuthKey(account: viewModel.accounts.first!.config) { result in
//                    let key = try? result.get()
//                    print(key)
//                    print(key!.data!.authkey)
//                    print(key!.data!.authkey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)
//                    if let key = key {
//                        print(genGachaURL(account: viewModel.accounts.first!.config, authkey: key.data!))
//                    }
//                }
//            }
//            if let url = url {
//                Text("\(url)")
//            }
//        }
//    }
// }
