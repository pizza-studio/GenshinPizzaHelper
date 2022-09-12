//
//  ContentView.swift
//  WatchHelper WatchKit Extension
//
//  Created by Bill Haku on 2022/9/8.
//

import SwiftUI
import WidgetKit

let testCookie = "CNZZDATA1275023096=370752618-1660798325-%7C1660798325; .thumbcache_a5f2da7236017eb7e922ea0d742741d5=tt0wiJai3iiGz19nD3q4Rb7XzX2e9h269dgd1pkL8fGAMSaQ66+xpVcxvUVia0dSkKZf9FJpROf1zWGKBRJMXw%3D%3D; smidV2=20220818133455ec621bd09663d7845f493a845c7a0ef200320ca714796d080; aliyungf_tc=3bbefcd84682e42d67562714b207c18fb2f5e18fb4d763fb33479d54f2ee8b94; aliyungf_tc=7231e2a94883d947a457d8caada821efc4c3426699241ee667a5c1071f3d04d5; UM_distinctid=182af7287461126-05b7d2f6a28666-744c1151-505c8-182af72874711db; _MHYUUID=fbaf2d8a-7c06-415d-ae78-8f022739f72b; _ga=GA1.2.686101694.1660800896; _gid=GA1.2.1232564546.1660800896; _gat=1; ltoken=SANITIZED ltuid=20953693; cookie_token=SANITIZED account_id=20953693; acw_tc=0a362b5e16608008957592320e0b965779d5ce26f921d7d750b4fb5ff280cd; "

let testCookie2 = "ltoken=SANITIZED ltuid=18132140; account_id=18132140; cookie_token=SANITIZED aliyungf_tc=3d928ac5ead791925b651ed35dde961810f1471fa669a3a75a53779be68d7111; _MHYUUID=8e1c5fea-a9ff-48ec-9067-dfff5d0d552b; _ga=GA1.2.305823812.1646043835; _gid=GA1.2.1561674501.1646487790; mi18nLang=en-us; UM_distinctid=17f3fdba4c26ea-0c8959b11c7fe5-3d62684b-4da900-17f3fdba4c3cf9"

let testCookie3 = "CNZZDATA1275023096=999975012-1661559467-%7C1661559467; .thumbcache_a5f2da7236017eb7e922ea0d742741d5=htxWcTkCYBFwzfBL9oHxx3ksA0wMRXmgyywwSP/kjhXNwAFzKGmjPhyUFEy4heM6jvXCm0wgQyH0veCgjejthw%3D%3D; smidV2=20220827090539fabcd150bb205e9263de3c3b7bfec0ca0092bacb4ae3e7230; aliyungf_tc=ebfa3710b99973e110f7a0c1b73c63717e32ada696d8ddd04fe8447f8fa9cf17; aliyungf_tc=631ecca3b204af71d56cea3281e458d0f6b48b7b60001945f1f0a35fa37cba58; UM_distinctid=182dcd53c311008-0959e9d1a4454f-744c1251-505c8-182dcd53c321141; _MHYUUID=1c9862cb-d479-4173-9df3-22277bbadf23; ltoken=SANITIZED ltuid=114514004; cookie_token=SANITIZED account_id=114514004; acw_tc=2f6fc10a16615623402421910e9ff5791ed31292006540147220721c1d9fc4; "

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationView {
            if viewModel.accounts.isEmpty {
                VStack {
                    Text("请等待帐号从iCloud同步")
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                    Image(systemName: "icloud.and.arrow.down")
                    ProgressView()
                }
            } else {
                List {
                    ForEach($viewModel.accounts, id: \.config.uuid) { $account in
                        NavigationLink(destination: WatchAccountDetailView(userData: account.result, accountName: account.config.name, uid: account.config.uid)) {
                            WatchGameInfoBlock(userData: account.result, accountName: account.config.name, uid: account.config.uid)
                        }
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .listRowBackground(Color.white.opacity(0))
                    }
                }
                .listStyle(.carousel)
            }
        }
        .onChange(of: scenePhase, perform: { newPhase in
            switch newPhase {
            case .active:
                DispatchQueue.main.async {
                    viewModel.fetchAccount()
                }
                DispatchQueue.main.async {
                    viewModel.refreshData()
                }
            case .inactive:
                if #available(watchOSApplicationExtension 9.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            default:
                break
            }
        })
//        .onAppear {
//            viewModel.deleteAccount(account: viewModel.accounts.first!)
//            viewModel.addAccount(name: "Hotaru", uid: "114514002", cookie: testCookie, server: .china)
//            viewModel.addAccount(name: "Lumine", uid: "137735830", cookie: testCookie2, server: .china)
//            viewModel.addAccount(name: "Lava", uid: "114514001", cookie: testCookie3, server: .china)
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
