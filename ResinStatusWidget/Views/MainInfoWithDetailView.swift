//
//  MainInfoWithDetailView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation
import SwiftUI

struct MainInfoWithDetail: View {
    let userData: UserData
    let viewConfig: WidgetViewConfiguration

    var body: some View {
        HStack {
            
            Spacer()
            MainInfo(userData: userData, viewConfig: viewConfig)
                .padding()
                
            Spacer()
            DetailInfo(userData: userData, viewConfig: viewConfig)
                .padding([.vertical])
            Spacer()
        }
        
    }
}
