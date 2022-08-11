//
//  ResinView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation
import SwiftUI

struct ResinView: View {
    let resinInfo: ResinInfo
    
    var condensedResin: Int { resinInfo.currentResin / 40 }
    
    var body: some View {

        VStack(spacing: 0) {
            if condensedResin > 0 {
                HStack(spacing: 0) {
                    ForEach(1...condensedResin, id: \.self) { _ in
                        Image("浓缩树脂")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(maxWidth: 100, maxHeight: 30)
            } else {
                Image("树脂")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 100, maxHeight: 30)
            }

            Text("\(resinInfo.currentResin)")
                .font(.system(size: 50 , design: .rounded))
                .fontWeight(.medium)
//                .gradientForeground(colors: textColors)
                .foregroundColor(Color("textColor3"))
                .shadow(radius: 1)
        }
    }
}
