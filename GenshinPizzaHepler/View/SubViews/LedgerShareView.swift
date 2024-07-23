//
//  LedgerShareView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/14.
//

import HoYoKit
import SwiftPieChart
import SwiftUI

// MARK: - LedgerShareView

@available(iOS 15.0, *)
struct LedgerShareView: View {
    let data: LedgerData

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                let income = String(format: "app.ledger.primogem.income.title:%lld".localized, data.dataMonth)
                Text(income)
                    .font(.title).bold()
                PieChartView(
                    values: data.monthData.groupBy.map { Double($0.num) },
                    names: data.monthData.groupBy.map { $0.action },
                    formatter: { value in String(format: "%.0f", value) },
                    colors: [
                        .blue,
                        .green,
                        .orange,
                        .yellow,
                        .purple,
                        .gray,
                        .brown,
                        .cyan,
                    ],
                    backgroundColor: Color(UIColor.systemBackground),
                    innerRadiusFraction: 0.6
                )
            }
            .frame(width: 300, height: 700)
            HStack {
                Image("AppIconHD")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Text("app.title.full").bold().font(.footnote)
            }
        }
        .padding()
        .background(Color.white)
    }
}

// MARK: - LedgerDataActions

public enum LedgerDataActions: Int, CaseIterable {
    case byOther = 0
    case byAdventure = 1
    case byTask = 2
    case byActivity = 3
    case byAbyss = 4
    case byMail = 5
    case byEvent = 6
}

extension LedgerDataActions {
    public var localizedKey: String {
        "ledgerData.action.name.\(String(describing: self))"
    }

    public var localized: String {
        localizedKey.localized
    }
}
