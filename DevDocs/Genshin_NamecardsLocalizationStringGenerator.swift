#!/usr/bin/env swift

import Foundation

let rawData: String = """
Key	en	chs	cht	jp	kr	fr	it	ru	de	vi
$asset.nameCard:UI_NameCardPic_Liuyun_P	Xianyun: White Clouds	闲云·鹤云	閒雲·鶴雲	閑雲·鶴雲	한운·학 구름	Xianyun – Nuage blanc	Xianyun – Nuage blanc	Белые облака	Xianyun – Weiße Wolken	Xianyun – Mây Trắng
$asset.nameCard:UI_NameCardPic_Gaming_P	Gaming: Man Chai	嘉明·文仔	嘉明·文仔	嘉明·ウェンツァイ	가명·문동이	Gaming – Man Chai	Gaming – Man Chai	Ман Чай	Gaming – Man Chai	Gaming – A Văn
"""

// MARK: - LangTag

public enum LangTag: Int, CaseIterable {
    case en = 1
    case chs = 2
    case cht = 3
    case jp = 4
    case kr = 5
    case fr = 6
    case it = 7
    case ru = 8
    case de = 9
    case vi = 10

    // MARK: Public

    public var toString: String {
        String(describing: self)
    }
}

// MARK: - NameCardAsset

public struct NameCardAsset {
    public var langDict: [LangTag: String] = [:]
    public var i18nKey: String = ""
}

var lineNumber = 0
var allAssets: [NameCardAsset] = []

rawData.enumerateLines { currentLine, _ in
    defer { lineNumber += 1 }
    let lineCells = currentLine.split(separator: "\t")
    guard lineCells.count == 11 else { return }
    guard lineNumber != 0 else { return }
    var asset = NameCardAsset()
    lineCells.enumerated().forEach { cellID, cell in
        switch cellID {
        case 0: asset.i18nKey = cell.description
        default:
            guard let tag = LangTag(rawValue: cellID) else { return }
            asset.langDict[tag] = cell.description
        }
    }
    allAssets.append(asset)
}

extension Array where Element == NameCardAsset {
    func printLang(tag: LangTag) {
        forEach { asset in
            guard let translatedText = asset.langDict[tag] else { return }
            print("\"\(asset.i18nKey)\" = \"\(translatedText)\";")
        }
    }
}

LangTag.allCases.forEach { tag in
    print("// " + tag.toString)
    allAssets.printLang(tag: tag)
    print("")
}
