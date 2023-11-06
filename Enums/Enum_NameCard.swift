//
//  Namecards.swift
//  GenshinPizzaHepler
//
//  Created by ShikiSuen on 2023/10/3.
//

import Defaults
import Foundation
import UIKit

// MARK: - NameCard

/// 原神名片清单，按照 Ambr.top 网页陈列顺序排列。
public enum NameCard: Int, CaseIterable {
    case UI_NameCardPic_0_P = 210001
    case UI_NameCardPic_Bp1_P = 210002
    case UI_NameCardPic_Ambor_P = 210003
    case UI_NameCardPic_Klee_P = 210004
    case UI_NameCardPic_Diluc_P = 210005
    case UI_NameCardPic_Razor_P = 210006
    case UI_NameCardPic_Venti_P = 210007
    case UI_NameCardPic_Qin_P = 210008
    case UI_NameCardPic_Barbara_P = 210009
    case UI_NameCardPic_Kaeya_P = 210010
    case UI_NameCardPic_Lisa_P = 210011
    case UI_NameCardPic_Sucrose_P = 210012
    case UI_NameCardPic_Fischl_P = 210013
    case UI_NameCardPic_Noel_P = 210014
    case UI_NameCardPic_Mona_P = 210015
    case UI_NameCardPic_Bennett_P = 210016
    case UI_NameCardPic_Xiangling_P = 210017
    case UI_NameCardPic_Xingqiu_P = 210018
    case UI_NameCardPic_Qiqi_P = 210019
    case UI_NameCardPic_Keqing_P = 210020
    case UI_NameCardPic_Csxy1_P = 210021
    case UI_NameCardPic_Mxsy_P = 210022
    case UI_NameCardPic_Yxzl_P = 210023
    case UI_NameCardPic_Md_P = 210024
    case UI_NameCardPic_Ly_P = 210025
    case UI_NameCardPic_Yszj_P = 210026
    case UI_NameCardPic_Sss_P = 210027
    case UI_NameCardPic_Tzz1_P = 210028
    case UI_NameCardPic_Sj1_P = 210029
    case UI_NameCardPic_Olah1_P = 210030
    case UI_NameCardPic_Zdg1_P = 210031
    case UI_NameCardPic_Lyws1_P = 210032
    case UI_NameCardPic_Ysxf1_P = 210033
    case UI_NameCardPic_Ningguang_P = 210038
    case UI_NameCardPic_Beidou_P = 210039
    case UI_NameCardPic_Chongyun_P = 210040
    case UI_NameCardPic_Tzz2_P = 210041
    case UI_NameCardPic_Bp2_P = 210042
    case UI_NameCardPic_Diona_P = 210043
    case UI_NameCardPic_Zhongli_P = 210044
    case UI_NameCardPic_Xinyan_P = 210045
    case UI_NameCardPic_Tartaglia_P = 210046
    case UI_NameCardPic_Md2_P = 210047
    case UI_NameCardPic_Md1_P = 210048
    case UI_NameCardPic_Ly1_P = 210049
    case UI_NameCardPic_Ly2_P = 210050
    case UI_NameCardPic_Tzz3_P = 210051
    case UI_NameCardPic_Xssdlk_P = 210052
    case UI_NameCardPic_Ganyu_P = 210053
    case UI_NameCardPic_Albedo_P = 210054
    case UI_NameCardPic_Bp3_P = 210055
    case UI_NameCardPic_ElderTree_P = 210056
    case UI_NameCardPic_EffigyChallenge_P = 210057
    case UI_NameCardPic_Xiao_P = 210058
    case UI_NameCardPic_Hutao_P = 210059
    case UI_NameCardPic_Bp4_P = 210060
    case UI_NameCardPic_LanternRite_P = 210061
    case UI_NameCardPic_TheatreMechanicus_P = 210062
    case UI_NameCardPic_Rosaria_P = 210063
    case UI_NameCardPic_Bp5_P = 210064
    case UI_NameCardPic_RedandWhite_P = 210065
    case UI_NameCardPic_Razer_P = 210066
    case UI_NameCardPic_ChannellerSlab_P = 210067
    case UI_NameCardPic_HideandSeek_P = 210068
    case UI_NameCardPic_Feiyan_P = 210069
    case UI_NameCardPic_Eula_P = 210070
    case UI_NameCardPic_Bp6_P = 210071
    case UI_NameCardPic_Homeworld_P = 210072
    case UI_NameCardPic_Kazuha_P = 210073
    case UI_NameCardPic_Bp7_P = 210074
    case UI_NameCardPic_Homeworld1_P = 210075
    case UI_NameCardPic_Google_P = 210076
    case UI_NameCardPic_BounceConjuringChallenge_P = 210077
    case UI_NameCardPic_EffigyChallenge02_P = 210078
    case UI_NameCardPic_Oraionokami_P = 210079
    case UI_NameCardPic_Bp8_P = 210080
    case UI_NameCardPic_Ayaka_P = 210081
    case UI_NameCardPic_Yoimiya_P = 210082
    case UI_NameCardPic_Sayu_P = 210083
    case UI_NameCardPic_Dq1_P = 210084
    case UI_NameCardPic_Dq2_P = 210085
    case UI_NameCardPic_Ysxf2_P = 210086
    case UI_NameCardPic_Csxy2_P = 210087
    case UI_NameCardPic_Tzz4_P = 210088
    case UI_NameCardPic_Homeworld2_P = 210089
    case UI_NameCardPic_Daoqi1_P = 210090
    case UI_NameCardPic_TheatreMechanicus2_P = 210091
    case UI_NameCardPic_Shougun_P = 210092
    case UI_NameCardPic_Kokomi_P = 210093
    case UI_NameCardPic_Sara_P = 210094
    case UI_NameCardPic_Aloy_P = 210095
    case UI_NameCardPic_Bp9_P = 210096
    case UI_NameCardPic_Daoqi2_P = 210097
    case UI_NameCardPic_Fishing_P = 210098
    case UI_NameCardPic_Concert_P = 210099
    case UI_NameCardPic_Sumo_P = 210100
    case UI_NameCardPic_Tohma_P = 210101
    case UI_NameCardPic_Bp10_P = 210102
    case UI_NameCardPic_Daoqi3_P = 210103
    case UI_NameCardPic_Gorou_P = 210104
    case UI_NameCardPic_Itto_P = 210105
    case UI_NameCardPic_Bp11_P = 210106
    case UI_NameCardPic_Shenhe_P = 210107
    case UI_NameCardPic_Yunjin_P = 210108
    case UI_NameCardPic_Daoqi4_P = 210109
    case UI_NameCardPic_Bp12_P = 210110
    case UI_NameCardPic_Bartender_P = 210111
    case UI_NameCardPic_Yae1_P = 210112
    case UI_NameCardPic_Bp13_P = 210113
    case UI_NameCardPic_Ayato_P = 210114
    case UI_NameCardPic_LuminanceStone_P = 210115
    case UI_NameCardPic_Tzz5_P = 210116
    case UI_NameCardPic_Cenyan1_P = 210117
    case UI_NameCardPic_Bp14_P = 210118
    case UI_NameCardPic_Yelan_P = 210119
    case UI_NameCardPic_Shinobu_P = 210120
    case UI_NameCardPic_Bp15_P = 210121
    case UI_NameCardPic_Heizo_P = 210122
    case UI_NameCardPic_Bp16_P = 210123
    case UI_NameCardPic_Tighnari_P = 210124
    case UI_NameCardPic_Collei_P = 210125
    case UI_NameCardPic_Dori_P = 210126
    case UI_NameCardPic_Bp17_P = 210127
    case UI_NameCardPic_Csxy3_P = 210128
    case UI_NameCardPic_Ysxf3_P = 210129
    case UI_NameCardPic_Xm1_P = 210130
    case UI_NameCardPic_Xumi1_P = 210131
    case UI_NameCardPic_Xumi2_P = 210132
    case UI_NameCardPic_Bp18_P = 210133
    case UI_NameCardPic_Cyno_P = 210134
    case UI_NameCardPic_Candace_P = 210135
    case UI_NameCardPic_Nilou_P = 210136
    case UI_NameCardPic_Yszj2_P = 210137
    case UI_NameCardPic_Xm2_P = 210138
    case UI_NameCardPic_Tzz6_P = 210139
    case UI_NameCardPic_Nahida_P = 210140
    case UI_NameCardPic_Layla_P = 210141
    case UI_NameCardPic_Bp19_P = 210142
    case UI_NameCardPic_Wanderer_P = 210143
    case UI_NameCardPic_Faruzan_P = 210144
    case UI_NameCardPic_Gcg1_P = 210145
    case UI_NameCardPic_Bp20_P = 210146
    case UI_NameCardPic_Alhatham_P = 210147
    case UI_NameCardPic_Yaoyao_P = 210148
    case UI_NameCardPic_Cadillac_P = 210149
    case UI_NameCardPic_Bp21_P = 210150
    case UI_NameCardPic_Xm3_P = 210151
    case UI_NameCardPic_Dehya_P = 210152
    case UI_NameCardPic_Mika_P = 210153
    case UI_NameCardPic_Bp22_P = 210154
    case UI_NameCardPic_Baizhuer_P = 210155
    case UI_NameCardPic_Kaveh_P = 210156
    case UI_NameCardPic_Xm4_P = 210157
    case UI_NameCardPic_Tzz7_P = 210158
    case UI_NameCardPic_Vasara_P = 210159
    case UI_NameCardPic_OfferingPari_P = 210160
    case UI_NameCardPic_Bp23_P = 210161
    case UI_NameCardPic_Kirara_P = 210162
    case UI_NameCardPic_Bp24_P = 210163
    case UI_NameCardPic_Bp25_P = 210164
    case UI_NameCardPic_Liney_P = 210165
    case UI_NameCardPic_Linette_P = 210166
    case UI_NameCardPic_Freminet_P = 210167
    case UI_NameCardPic_FD1_P = 210168
    case UI_NameCardPic_Ysxf4_P = 210169
    case UI_NameCardPic_Csxy4_P = 210170
    case UI_NameCardPic_Fontaine1_P = 210171
    case UI_NameCardPic_Fontaine2_P = 210172
    case UI_NameCardPic_Bp26_P = 210173
    case UI_NameCardPic_Neuvillette_P = 210174
    case UI_NameCardPic_Wriothesley_P = 210175
    case UI_NameCardPic_Bp27_P = 210176
    case UI_NameCardPic_Guqin_P = 210177
    case UI_NameCardPic_Tzz8_P = 210178
    case UI_NameCardPic_FD2_P = 210179
    case UI_NameCardPic_Furina_P = 210180
    case UI_NameCardPic_Charlotte_P = 210181
    case UI_NameCardPic_FD3_P = 210182
    case UI_NameCardPic_Bp28_P = 210183
}

extension NameCard {
    /// 此变数用来屏蔽某些正式发行前的内容。
    /// 之所以仅对名片与材料这么做，是因为角色往往会提前一个月被米哈游官方借由「天外卫星通信」公开。
    /// 加上 .release(since:.Specify(day:month:year:)) 后缀可以使禁令定时消除。
    /// 建议消除的时间为新版发行之前的纪行的结束日之后的那天。
    public static var blacklist: [NameCard] {
        [
            // 此处插入的内容的范例：.UI_NameCardPic_Furina_P.release(since: .Specify(day: 7, month: 11, year: 2023)),
        ].compactMap { $0 }
    }

    public static var allLegalCases: [NameCard] {
        var result = allCases
        result.removeAll {
            Self.blacklist.contains($0)
        }
        return result
    }

    public static var defaultValue: NameCard { .UI_NameCardPic_Bp20_P }

    public static var random: NameCard { allLegalCases.randomElement() ?? .defaultValue }

    /// 自指定日期開始返回 nil。
    /// - Parameter date: 指定日期
    /// - Returns: 自指定日期開始返回 nil。
    public func release(since date: Date?) -> NameCard? {
        guard let date = date else { return self }
        return Date() < date ? self : nil
    }
}

extension NameCard {
    public var fileName: String { .init(describing: self) }

    // 之前的 UserDefaults 参数值是简体中文，且中间的点的符号用的是不同的 Unicode 字元。
    // 请勿主动使用该参数，除非是为了将使用者的旧版 UserDefaults 参数设定做自动纠偏处理。
    public var deprecatedRawFilename: String {
        "$asset.nameCard:\(fileName)".i18n("zh-Hans").replacingOccurrences(of: "·", with: "・")
    }

    public var localizedKey: String {
        var raw = fileName
        if Defaults[.useActualCharacterNames], raw.contains("_Wanderer_") {
            raw = raw.replacingOccurrences(of: "Wanderer", with: "Kunikuzushi")
        }
        return "$asset.nameCard:" + raw
    }

    public var localized: String {
        if Defaults[.useActualCharacterNames], fileName.contains("Kunikuzushi") {
            return localizedKey.localized
        }
        return localizedKey.localized.localizedWithFix
    }
}

#if !os(watchOS)
extension NameCard {
    public var smallImage: UIImage? { UIImage(named: fileName) }
}
#endif
