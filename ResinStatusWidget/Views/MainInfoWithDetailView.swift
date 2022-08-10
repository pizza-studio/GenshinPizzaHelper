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

    var body: some View {
        HStack {
            Spacer()
            MainInfo(userData: userData)
                .padding(.vertical)
            Spacer()
            DetailInfo(userData: userData)
                .padding(.vertical)
            Spacer()
        }
    }
}
