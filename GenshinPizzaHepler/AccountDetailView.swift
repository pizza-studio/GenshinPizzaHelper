//
//  AccountDetailView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct AccountDetailView: View {
    @StateObject var viewModel = ViewModel()
    @AppStorage("accountName", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountName: String = "0"
    @AppStorage("uid", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var uid: String = "0"
    @AppStorage("cookie", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var cookie: String?
    @AppStorage("server", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var server: Server = .china
    var body: some View {
        List {
            NavigationLink(destination: TextEditorView(content: $accountName)) {
                InfoPreviewer(title: "账户名", content: accountName)
            }
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
