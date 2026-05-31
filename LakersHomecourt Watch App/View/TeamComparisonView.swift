//
//  TeamComparisonView.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI

struct TeamComparisonView: View {

    let data: TeamComparisonResponse

    struct StatRow: Identifiable {
        let id    = UUID()
        let label: String
        let lakers: Double
        let opposing: Double
    }

    var stats: [StatRow] {[
        StatRow(label: "Rebounds", lakers: Double(data.lakers_rebounds),  opposing: Double(data.opposing_rebounds)),
        StatRow(label: "Assists",  lakers: Double(data.lakers_assists),   opposing: Double(data.opposing_assists)),
        StatRow(label: "Steals",   lakers: Double(data.lakers_steals),    opposing: Double(data.opposing_steals)),
    ]}

    var body: some View {
        ZStack {
            appGradient.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 10) {

                HStack() {
                    LegendDot(color: .lakersGold, label: "LA")
                    Spacer()
                    LegendDot(color: .gswGray,    label: "OPP")
                }
                .padding(.bottom, 2).padding(.horizontal)

                ForEach(stats) { stat in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.label)
                            .font(.graphik(12))
                            .foregroundColor(.white).padding(.top,5)

                        GeometryReader { geo in
                            let total  = stat.lakers + stat.opposing
                            let lWidth = geo.size.width * CGFloat(stat.lakers   / total)
                            let gWidth = geo.size.width * CGFloat(stat.opposing / total)

                            HStack(spacing: 3) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.lakersGold)
                                    .frame(width: lWidth, height: 20)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gswGray.opacity(0.7))
                                    .frame(width: gWidth, height: 20)
                            }
                        }
                        .frame(height: 14)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

#Preview {
    TeamComparisonView(
        data: TeamComparisonResponse(
            game_id: 1,
            lakers_rebounds: 42,
            opposing_rebounds: 38,
            lakers_assists: 25,
            opposing_assists: 21,
            lakers_steals: 9,
            opposing_steals: 6
        )
    )
}
