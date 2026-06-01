//
//  TeamComparisonView.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI

struct TeamComparisonView: View {

    let data: TeamComparisonResponse
    let lakersName: String
    let opposingName: String

    struct StatRow: Identifiable {
        let id = UUID()
        let label: String
        let lakers: Double
        let opposing: Double
    }

    var stats: [StatRow] {[
        StatRow(label: "Rebounds", lakers: Double(data.lakers_rebounds),  opposing: Double(data.opposing_rebounds)),
        StatRow(label: "Assists",  lakers: Double(data.lakers_assists),   opposing: Double(data.opposing_assists)),
        StatRow(label: "Steals",   lakers: Double(data.lakers_steals),    opposing: Double(data.opposing_steals))
    ]}

    var body: some View {
        ZStack {
            appGradient.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 10) {

                ForEach(stats) { stat in
                    StatBarRow(stat: stat)
                }

                HStack {
                    LegendDot(color: .lakersGold, label: lakersName)
                    Spacer()
                    HStack(spacing: 5) {
                        Text(opposingName)
                            .font(.graphik(10))
                            .foregroundColor(.white)
                        Circle()
                            .fill(Color.gswGray)
                            .frame(width: 6)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 5)
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
        ),
        lakersName: "LA",
        opposingName: "GS"
    )
}
