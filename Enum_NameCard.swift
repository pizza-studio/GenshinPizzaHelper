//
//  Namecards.swift
//  GenshinPizzaHepler
//
//  Created by ShikiSuen on 2023/10/3.
//

import Foundation

// MARK: - NameCard

/// 原神名片清单，按照 Ambr.top 网页陈列顺序排列。
public enum NameCard: String, CaseIterable {
    case UI_NameCardPic_0_P
    case UI_NameCardPic_Bp10_P
    case UI_NameCardPic_Ambor_P
    case UI_NameCardPic_Klee_P
    case UI_NameCardPic_Diluc_P
    case UI_NameCardPic_Razor_P
    case UI_NameCardPic_Venti_P
    case UI_NameCardPic_Qin_P
    case UI_NameCardPic_Barbara_P
    case UI_NameCardPic_Kaeya_P
    case UI_NameCardPic_Lisa_P
    case UI_NameCardPic_Sucrose_P
    case UI_NameCardPic_Fischl_P
    case UI_NameCardPic_Noel_P
    case UI_NameCardPic_Mona_P
    case UI_NameCardPic_Bennett_P
    case UI_NameCardPic_Xiangling_P
    case UI_NameCardPic_Xingqiu_P
    case UI_NameCardPic_Qiqi_P
    case UI_NameCardPic_Keqing_P
    case UI_NameCardPic_Csxy1_P
    case UI_NameCardPic_Mxsy_P
    case UI_NameCardPic_Yxzl_P
    case UI_NameCardPic_Md1_P
    case UI_NameCardPic_Ly1_P
    case UI_NameCardPic_Yszj2_P
    case UI_NameCardPic_Sss_P
    case UI_NameCardPic_Tzz1_P
    case UI_NameCardPic_Sj1_P
    case UI_NameCardPic_Olah1_P
    case UI_NameCardPic_Zdg1_P
    case UI_NameCardPic_Ly_P
    case UI_NameCardPic_Ysxf1_P
    case UI_NameCardPic_Ningguang_P
    case UI_NameCardPic_Beidou_P
    case UI_NameCardPic_Chongyun_P
    case UI_NameCardPic_Tzz2_P
    case UI_NameCardPic_Bp20_P
    case UI_NameCardPic_Diona_P
    case UI_NameCardPic_Zhongli_P
    case UI_NameCardPic_Xinyan_P
    case UI_NameCardPic_Tartaglia_P
    case UI_NameCardPic_Md_P
    case UI_NameCardPic_Md2_P
    case UI_NameCardPic_Ly2_P
    case UI_NameCardPic_Lyws1_P
    case UI_NameCardPic_Tzz3_P
    case UI_NameCardPic_Xssdlk_P
    case UI_NameCardPic_Ganyu_P
    case UI_NameCardPic_Albedo_P
    case UI_NameCardPic_Bp3_P
    case UI_NameCardPic_ElderTree_P
    case UI_NameCardPic_EffigyChallenge02_P
    case UI_NameCardPic_Xiao_P
    case UI_NameCardPic_Hutao_P
    case UI_NameCardPic_Bp4_P
    case UI_NameCardPic_LanternRite_P
    case UI_NameCardPic_TheatreMechanicus2_P
    case UI_NameCardPic_Rosaria_P
    case UI_NameCardPic_Bp5_P
    case UI_NameCardPic_RedandWhite_P
    case UI_NameCardPic_Razer_P
    case UI_NameCardPic_ChannellerSlab_P
    case UI_NameCardPic_HideandSeek_P
    case UI_NameCardPic_Feiyan_P
    case UI_NameCardPic_Eula_P
    case UI_NameCardPic_Bp6_P
    case UI_NameCardPic_Homeworld1_P
    case UI_NameCardPic_Kazuha_P
    case UI_NameCardPic_Bp7_P
    case UI_NameCardPic_Homeworld2_P
    case UI_NameCardPic_Google_P
    case UI_NameCardPic_BounceConjuringChallenge_P
    case UI_NameCardPic_EffigyChallenge_P
    case UI_NameCardPic_Oraionokami_P
    case UI_NameCardPic_Bp8_P
    case UI_NameCardPic_Ayaka_P
    case UI_NameCardPic_Yoimiya_P
    case UI_NameCardPic_Sayu_P
    case UI_NameCardPic_Dq1_P
    case UI_NameCardPic_Dq2_P
    case UI_NameCardPic_Ysxf2_P
    case UI_NameCardPic_Csxy2_P
    case UI_NameCardPic_Tzz4_P
    case UI_NameCardPic_Homeworld_P
    case UI_NameCardPic_Daoqi1_P
    case UI_NameCardPic_TheatreMechanicus_P
    case UI_NameCardPic_Shougun_P
    case UI_NameCardPic_Kokomi_P
    case UI_NameCardPic_Sara_P
    case UI_NameCardPic_Aloy_P
    case UI_NameCardPic_Bp9_P
    case UI_NameCardPic_Daoqi2_P
    case UI_NameCardPic_Fishing_P
    case UI_NameCardPic_Concert_P
    case UI_NameCardPic_Sumo_P
    case UI_NameCardPic_Tohma_P
    case UI_NameCardPic_Bp11_P
    case UI_NameCardPic_Daoqi3_P
    case UI_NameCardPic_Gorou_P
    case UI_NameCardPic_Itto_P
    case UI_NameCardPic_Bp12_P
    case UI_NameCardPic_Shenhe_P
    case UI_NameCardPic_Yunjin_P
    case UI_NameCardPic_Daoqi4_P
    case UI_NameCardPic_Bp13_P
    case UI_NameCardPic_Bartender_P
    case UI_NameCardPic_Yae1_P
    case UI_NameCardPic_Bp14_P
    case UI_NameCardPic_Ayato_P
    case UI_NameCardPic_LuminanceStone_P
    case UI_NameCardPic_Tzz5_P
    case UI_NameCardPic_Cenyan1_P
    case UI_NameCardPic_Bp15_P
    case UI_NameCardPic_Yelan_P
    case UI_NameCardPic_Shinobu_P
    case UI_NameCardPic_Bp16_P
    case UI_NameCardPic_Heizo_P
    case UI_NameCardPic_Bp17_P
    case UI_NameCardPic_Tighnari_P
    case UI_NameCardPic_Collei_P
    case UI_NameCardPic_Dori_P
    case UI_NameCardPic_Bp18_P
    case UI_NameCardPic_Csxy3_P
    case UI_NameCardPic_Ysxf3_P
    case UI_NameCardPic_Xm1_P
    case UI_NameCardPic_Xumi1_P
    case UI_NameCardPic_Xumi2_P
    case UI_NameCardPic_Bp19_P
    case UI_NameCardPic_Cyno_P
    case UI_NameCardPic_Candace_P
    case UI_NameCardPic_Nilou_P
    case UI_NameCardPic_Yszj_P
    case UI_NameCardPic_Xm2_P
    case UI_NameCardPic_Tzz6_P
    case UI_NameCardPic_Nahida_P
    case UI_NameCardPic_Layla_P
    case UI_NameCardPic_Bp1_P
    case UI_NameCardPic_Wanderer_P
    case UI_NameCardPic_Faruzan_P
    case UI_NameCardPic_Gcg1_P
    case UI_NameCardPic_Bp21_P
    case UI_NameCardPic_Alhatham_P
    case UI_NameCardPic_Yaoyao_P
    case UI_NameCardPic_Cadillac_P
    case UI_NameCardPic_Bp22_P
    case UI_NameCardPic_Xm3_P
    case UI_NameCardPic_Dehya_P
    case UI_NameCardPic_Mika_P
    case UI_NameCardPic_Bp23_P
    case UI_NameCardPic_Baizhuer_P
    case UI_NameCardPic_Kaveh_P
    case UI_NameCardPic_Xm4_P
    case UI_NameCardPic_Tzz7_P
    case UI_NameCardPic_Vasara_P
    case UI_NameCardPic_OfferingPari_P
    case UI_NameCardPic_Bp24_P
    case UI_NameCardPic_Kirara_P
    case UI_NameCardPic_Bp25_P
    case UI_NameCardPic_Bp26_P
    case UI_NameCardPic_Liney_P
    case UI_NameCardPic_Linette_P
    case UI_NameCardPic_Freminet_P
    case UI_NameCardPic_FD1_P
    case UI_NameCardPic_Ysxf4_P
    case UI_NameCardPic_Csxy4_P
    case UI_NameCardPic_Fontaine1_P
    case UI_NameCardPic_Fontaine2_P
    case UI_NameCardPic_Bp27_P
    case UI_NameCardPic_Neuvillette_P
    case UI_NameCardPic_Wriothesley_P
    case UI_NameCardPic_Bp28_P
    case UI_NameCardPic_Guqin_P
    case UI_NameCardPic_Tzz8_P
    case UI_NameCardPic_FD2_P
    // case UI_NameCardPic_Furina_P // 原神 4.2
    // case UI_NameCardPic_Charlotte_P // 原神 4.2
    // case UI_NameCardPic_FD3_P // 原神 4.2
    // case UI_NameCardPic_Bp2_P // 原神 4.2
}

extension NameCard {
    public var localizedKey: String {
        var raw = rawValue
        if raw.contains("_Wanderer_") { raw = raw.replacingOccurrences(of: "Wanderer", with: "Kunikuzushi") }
        return "namecards:" + raw
    }

    public var localized: String { localizedKey.localized.localizedWithFix }
}
