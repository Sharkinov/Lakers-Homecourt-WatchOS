//
//  StatBarRow.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 31/05/26.
//

import SwiftUI

struct StatBarRow: View {
    let stat: TeamComparisonView.StatRow

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(stat.label)
                .font(.graphik(12))
                .foregroundStyle(.white)
                .padding(.top, 5)

            GeometryReader { geo in
                StatBarGeometry(stat: stat, availableWidth: geo.size.width)
            }
            .frame(height: 12)
        }
    }
}

#Preview {
    StatBarRow(
        stat: TeamComparisonView.StatRow(
            label: "Rebounds",
            lakers: 42,
            opposing: 38
        )
    )
}
