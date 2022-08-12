//
//  WebImageView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/8/12.
//

import SwiftUI

struct WebImage: View {
    var urlStr: String

    @State var imageData: UIImage? = nil

    var body: some View {
        if #available(iOSApplicationExtension 15.0, *) {
            AsyncImage(url: URL(string: urlStr)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
        } else {
            // Fallback on earlier versions
            if imageData == nil {
                ProgressView()
                    .onAppear {
                        let url = URL(string: urlStr)
                        if url != nil {
                            DispatchQueue.global(qos: .background).async {
                                let data = try? Data(contentsOf: url!)
                                guard data != nil else {
                                    return
                                }
                                imageData = UIImage(data: data!)
                            }
                        }
                    }
            } else {
                Image(uiImage: imageData!)
                    .resizable()
            }
        }
    }
}
