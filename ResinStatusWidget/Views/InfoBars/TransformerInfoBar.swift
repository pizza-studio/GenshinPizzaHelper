//
//  TransformerInfoBar.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import SwiftUI

struct TransformerInfoBar: View {
    let transformerInfo: TransformerInfo
    
    var isTransformerCompleteImage: Image {
        transformerInfo.isComplete ? Image(systemName: "exclamationmark.circle") : Image(systemName: "hourglass.circle")
    }
    
    var body: some View {
        
        
        HStack(alignment: .center ,spacing: 8) {
            Image("参量质变仪")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isTransformerCompleteImage
                .foregroundColor(Color("textColor3"))
                .font(.system(size: 14))
            HStack(alignment: .lastTextBaseline, spacing:1) {
                Text(transformerInfo.recoveryTime.describeIntervalShort)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}
