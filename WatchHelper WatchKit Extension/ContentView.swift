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
