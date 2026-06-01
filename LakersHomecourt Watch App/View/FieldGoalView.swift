//
//  FieldGoalView.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI

struct FieldGoalView: View {

    let data: FieldGoalResponse
    let lakersName: String

    var pct: Double {
        data.fg_percentage / 100.0
    }

    var body: some View {

        ZStack {
            appGradient.ignoresSafeArea()

            VStack(spacing: 16) {

                HStack(spacing: 6) {

                    Circle()
                        .fill(Color.lakersGold)
                        .frame(width: 8, height: 8)

                    Text(lakersName)
                        .font(.graphik(13))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)

                ZStack {

                    Circle()
                        .stroke(
                            Color.white.opacity(0.12),
                            lineWidth: 16
                        )

                    Circle()
                        .trim(
                            from: 0,
                            to: CGFloat(pct)
                        )
                        .stroke(
                            Color.lakersGold,
                            style: StrokeStyle(
                                lineWidth: 16,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .shadow(
                            color: Color.lakersGold.opacity(0.35),
                            radius: 4
                        )

                    VStack {

                        Text("\(Int(data.fg_percentage))%")
                            .font(.graphik(20))
                            .foregroundStyle(.white)
                    }
                }
                .frame(
                    width: 105
                )

                Text("FIELD GOAL")
                    .font(.graphik(10))
                    .foregroundStyle(
                        .white.opacity(0.60)
                    )
                    .tracking(1.5).padding(.top, 5)
            }
        }
    }
}

#Preview {
    FieldGoalView(
        data: FieldGoalResponse(
            game_id: 1,
            fg_percentage: 47.5
        ),
        lakersName: "LAL"
    )
}
