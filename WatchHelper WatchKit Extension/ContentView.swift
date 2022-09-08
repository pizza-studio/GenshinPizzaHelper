//
//  ContentView.swift
//  WatchHelper WatchKit Extension
//
//  Created by Bill Haku on 2022/9/8.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.accounts.isEmpty {
                    Label("请先添加帐号", systemImage: "plus.circle")
                }
                else {
                    ForEach(viewModel.accounts, id: \.config.uuid) { account in
                        Text(account.config.name ?? "no name")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
