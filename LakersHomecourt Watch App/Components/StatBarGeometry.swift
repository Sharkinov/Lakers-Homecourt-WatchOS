//
//  StatBarGeometry.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 31/05/26.
//

import SwiftUI

struct StatBarGeometry: View {
    let stat: TeamComparisonView.StatRow
    let availableWidth: CGFloat

    private var total: Double { max(stat.lakers + stat.opposing, 1) }
    private var lakersRatio: Double { stat.lakers / total }
    private var barWidth: CGFloat { (availableWidth - 56) * CGFloat(lakersRatio) }

    var body: some View {
        HStack(spacing: 8) {
            Text("\(Int(stat.lakers))")
                .font(.graphik(12))
                .foregroundStyle(Color.lakersGold)
                .frame(width: 24, alignment: .trailing)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gswGray)

                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.lakersGold)
                    .frame(width: barWidth)
                    .shadow(color: .lakersGold.opacity(0.35), radius: 3)
            }

            Text("\(Int(stat.opposing))")
                .font(.graphik(12))
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 24, alignment: .leading)
        }
    }
}

#Preview {
    StatBarGeometry(stat: TeamComparisonView.StatRow(
        label: "Rebounds",
        lakers: 42,
        opposing: 38
    ), availableWidth: 200)
}
