//
//  GameInfoBlockView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct GameInfoBlock: View {
    var userData: UserData?
    let accountName: String?

    let viewConfig = WidgetViewConfiguration.defaultConfig
    
    
    
    var body: some View {
        
        if let userData = userData {
                        HStack {
                Spacer()
                
                
                
                
                VStack(alignment: .leading, spacing: 5) {
                    if let accountName = accountName {
                        
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Image(systemName: "person.fill")
                            Text(accountName)
                            
                        }
                        .font(.footnote)
                        .foregroundColor(Color("textColor3"))
                        
                    }
                    
                    
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        
                        Text("\(userData.resinInfo.currentResin)")
                            .font(.system(size: 50 , design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Color("textColor3"))
                            .shadow(radius: 1)
                        Image("树脂")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 30)
                            .alignmentGuide(.firstTextBaseline) { context in
                                context[.bottom] - 0.17 * context.height
                            }
                    }
                    HStack {
                        Image(systemName: "hourglass.circle")
                            .foregroundColor(Color("textColor3"))
                            .font(.title3)
                        RecoveryTimeText(resinInfo: userData.resinInfo)
                    }
                }
                    .padding()
                Spacer()
                DetailInfo(userData: userData, viewConfig: viewConfig)
                    .padding([.vertical])
                    .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
                Spacer()
            }
                        .background(WidgetBackgroundView(background: WidgetBackground.randomBackground, darkModeOn: true))

        } else {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }

        
    }
}
