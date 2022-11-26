//
//  MaterialWidget.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2022/11/27.
//

import Foundation
import SwiftUI
import WidgetKit

struct MaterialWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "MaterialWidget",
            provider: MaterialWidgetProvider())
        { entry in
            MaterialWidgetView(entry: entry)
        }
        .configurationDisplayName("今日材料")
        .description("展示今天可以获取的武器和天赋材料。")
        .supportedFamilies([.systemLarge])
    }
}

struct MaterialWidgetView: View {
    let entry: MaterialWidgetEntry
    var weaponMaterials: [WeaponOrTalentMaterial] { entry.weaponMaterials }
    var talentMaterials: [WeaponOrTalentMaterial] { entry.talentMateirals }

    let imageWidth = CGFloat(50)

    var body: some View {
        
        ZStack {
            WidgetBackgroundView(background: .randomNamecardBackground, darkModeOn: true)
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    Spacer()
                    ForEach(talentMaterials, id: \.imageString) { material in
                        HStack {
                            Image(material.imageString)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageWidth)
                            Text(material.displayName)
                                .foregroundColor(Color("textColor3"))
                                .bold()
                        }
                        Spacer()
                    }
                }
                .shadow(radius: 3)
                Spacer()
                VStack(alignment: .leading) {
                    Spacer()
                    ForEach(weaponMaterials, id: \.imageString) { material in
                        HStack {
                            Image(material.imageString)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageWidth)
                            Text(material.displayName)
                                .foregroundColor(Color("textColor3"))
                                .bold()
                        }
                        Spacer()
                    }
                }
                .shadow(radius: 3)
                Spacer()
            }
            .padding(3)
        }
    }
}

struct MaterialWidgetEntry: TimelineEntry {
    let date: Date
    let materialWeekday: MaterialWeekday
    let talentMateirals: [WeaponOrTalentMaterial]
    let weaponMaterials: [WeaponOrTalentMaterial]

    init() {
        self.date = Date()
        self.materialWeekday = .today()
        self.talentMateirals = TalentMaterialProvider(weekday: .today()).todaysMaterials
        self.weaponMaterials = WeaponMaterialProvider(weekday: .today()).todaysMaterials
    }
}

struct MaterialWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MaterialWidgetEntry {
        .init()
    }

    func getSnapshot(in context: Context, completion: @escaping (MaterialWidgetEntry) -> Void) {
        completion(.init())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MaterialWidgetEntry>) -> Void) {
        let startOfToday: Date = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow: Date = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        completion(.init(entries: [.init()], policy: .after(Calendar.current.date(bySettingHour: 4, minute: 1, second: 0, of: startOfTomorrow)!)))
    }
}
