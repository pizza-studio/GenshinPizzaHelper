//
//  AccountDetailView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct AccountDetailView: View {
    @StateObject var viewModel = ViewModel()
    @AppStorage("accountName", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountName: String?
    @AppStorage("uid", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var uid: String?
    @AppStorage("cookie", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var cookie: String?
    @AppStorage("server", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var server: Server = .china
    var body: some View {
        List {
            InfoPreviewer(title: "账户名", content: accountName ?? uid ?? "0")
            NavigationLink(destination: TextPlayerView(title: "Cookie", text: cookie!)) {
                Text("Cookie")
            }
            Picker("请选择服务器", selection: $server) {
                ForEach(Server.allCases, id: \.self) { server in
                    Text(server.rawValue)
                        .tag(server)
                }
            }
        }
    }
}

struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDetailView()
    }
}
