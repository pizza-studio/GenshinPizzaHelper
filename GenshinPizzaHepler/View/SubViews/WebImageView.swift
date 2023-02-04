//
//  WebImageView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/8/12.
//  封装了iOS 14与iOS 15中两种方法的异步加载网络图片的View

import SwiftUI

struct WebImage: View {
    var urlStr: String

    @State private var imageData: UIImage? = nil
    
    let imageFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Images")

    var body: some View {
        if #available(iOS 15.0, watchOS 8.0, *) {
            if imageData == nil {
                AsyncImage(
                            url: URL(string: urlStr),
                            transaction: Transaction(animation: .default)
                        ) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                let _ = DispatchQueue.main.async {
                                    saveImageCache(url: urlStr)
                                }
                            default:
                                ProgressView()
                                    .onAppear {
                                        DispatchQueue.global(qos: .background).async {
                                            self.imageData = loadImageCache(url: urlStr)
                                        }
                                        // self.imageData = loadImageCache(url: urlStr)
                                    }
                            }
                        }
            } else {
                Image(uiImage: imageData!)
                    .resizable().aspectRatio(contentMode: .fit)
            }
            
        } else {
            // Fallback on earlier versions
            if imageData == nil {
                ProgressView()
                    .onAppear {
                        imageData = loadImageCache(url: urlStr)
                        let url = URL(string: urlStr)
                        if url != nil {
                            DispatchQueue.global(qos: .background).async {
                                let data = try? Data(contentsOf: url!)
                                guard data != nil else {
                                    return
                                }
                                let imageFileURL = imageFolderURL.appendingPathComponent(url!.lastPathComponent)
                                try! data!.write(to: imageFileURL)
                                imageData = UIImage(data: data!)
                            }
                        }
                    }
            } else {
                Image(uiImage: imageData!)
                    .resizable().aspectRatio(contentMode: .fit)
            }
        }
    }

//    init(urlStr: String) {
//        self.urlStr = urlStr
//        self.imageData = loadImageCache(url: urlStr)
//    }
    
    // 判断是否存在缓存，否则保存图片
    func saveImageCache(url: String) {
        let imageURL = URL(string: url)!
        let imageFileURL = imageFolderURL.appendingPathComponent(imageURL.lastPathComponent)
        if !FileManager.default.fileExists(atPath: imageFileURL.path) {
            URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let data = data {
                    print("save: fileURL:\(imageFileURL)")
                    try! data.write(to: imageFileURL)
                }
            }.resume()
        }
    }
    
    // 读取图片
    func loadImageCache(url: String) -> UIImage? {
        let imageURL = URL(string: url)!
        
        if !FileManager.default.fileExists(atPath: imageFolderURL.path) {
            try! FileManager.default.createDirectory(at: imageFolderURL, withIntermediateDirectories: true, attributes: nil)
        }
        let imageFileURL = imageFolderURL.appendingPathComponent(imageURL.lastPathComponent)
        print("load: fileURL:\(imageFileURL)")
        if let image = UIImage(contentsOfFile: imageFileURL.path) {
            return image
        } else {
            return nil
        }
    }
}

/// 加载完图片后才会显示，不要放在UI中，可以放在静态的内容中如widget和保存的图片
struct NetworkImage: View {
    let url: URL?
    
    var body: some View {
        Group {
            if let url = url, let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                //         .aspectRatio(contentMode: .fill)
            }
            else {
                Image("placeholder-image")
            }
        }
    }
}

struct EnkaWebIcon: View {
    var iconString: String

    var body: some View {
        if let image = UIImage(named: iconString) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            WebImage(urlStr: "https://enka.network/ui/\(iconString).png")
        }
    }
}

struct HomeSourceWebIcon: View {
    var iconString: String

    var body: some View {
        if let image = UIImage(named: iconString) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            WebImage(urlStr: "http://ophelper.top/resource/\(iconString).png")
        }
    }
}

