//
//  Icon.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2023/6/12.
//

import Combine
import Foundation
import UIKit

// MARK: - Icon

struct Icon: Identifiable {
    let ordinal: Int
    let name: String?
    let imageName: String

    var id: String { imageName }
    var image: UIImage {
        .init(named: imageName) ?? .init()
    }
}

// MARK: Comparable

extension Icon: Comparable {
    static func < (lhs: Icon, rhs: Icon) -> Bool {
        lhs.ordinal < rhs.ordinal
    }
}

// MARK: - IconManager

final class IconManager: ObservableObject {
    // MARK: Lifecycle

    init() {
        let currentIconName = UIApplication.shared.alternateIconName
        self.icons = {
            guard let plistIcons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any] else {
                return []
            }
            var icons: [Icon] = []
            // 添加主要图标
            if let primaryIcon = plistIcons["CFBundlePrimaryIcon"] as? [String: Any],
               let files = primaryIcon["CFBundleIconFiles"] as? [String],
               let fileName = files.first {
                print("Set Icon: \(fileName) (nil, 0) Added")
                icons.append(Icon(ordinal: 0, name: nil, imageName: fileName))
            }
            // 添加备用图标
            if !UIApplication.shared.supportsAlternateIcons {
                print("not support alternate icons")
            }
            print("AlternateIcons: ")
            if let alternateIcons = plistIcons["CFBundleAlternateIcons"] as? [String: Any] {
                if icons.isEmpty {
                    print("Alternate Icons is empty")
                }
                for icons in alternateIcons {
                    print(icons.key)
                }
            } else {
                print("Alternate Icons is nil")
            }
            if let alternateIcons = plistIcons["CFBundleAlternateIcons"] as? [String: Any] {
                icons += alternateIcons.compactMap { key, value in
                    guard let alternateIcon = value as? [String: Any],
                          let files = alternateIcon["CFBundleIconFiles"] as? [String],
                          let fileName = files.first,
                          let ordinal = alternateIcon["ordinal"] as? Int else {
                        return nil
                    }
                    print("Set Icon: \(fileName) (\(key), \(ordinal)) Added")
                    return Icon(ordinal: ordinal, name: key, imageName: fileName)
                }
                .sorted()
            }
            return icons
        }()
        self.currentIcon = icons.first { $0.name == currentIconName }
    }

    // MARK: Internal

    static let shared = IconManager()

    let icons: [Icon]

    @Published
    private(set) var currentIcon: Icon?
}

extension IconManager {
    @MainActor
    func set(icon: Icon) async throws {
        do {
            print("Set Icon: \(icon.imageName) (\(icon.id), \(icon.ordinal)) Set")
            try await UIApplication.shared.setAlternateIconName(icon.name)
            currentIcon = icon
        } catch {
            print("Set Icon Error: \(error)")
            throw error
        }
    }
}
