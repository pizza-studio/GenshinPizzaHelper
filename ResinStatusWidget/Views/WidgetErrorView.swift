//
//  ErrorView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import SwiftUI

struct WidgetErrorView: View {
    let error: FetchError
    
    var body: some View {
        Text(error.description)
            .font(.title2)
            .foregroundColor(.white)
    }
}

struct WidgetErrorView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetErrorView(error: .unknownError(1, "2"))
    }
}
