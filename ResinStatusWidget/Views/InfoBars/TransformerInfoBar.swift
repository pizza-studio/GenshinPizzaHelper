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
        transformerInfo.isComplete ? Image(systemName: "exclamationmark") : Image(systemName: "hourglass")
    }
    
    var body: some View {
        
        
        HStack(alignment: .center ,spacing: 8) {
            Image("参量质变仪")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isTransformerCompleteImage
                .overlayImageWithRingProgressBar(transformerInfo.percentage)
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3"))
            HStack(alignment: .lastTextBaseline, spacing:1) {
                Text(transformerInfo.recoveryTime.describeIntervalShort)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}
