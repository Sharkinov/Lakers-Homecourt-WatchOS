//
//  FieldGoalView.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI

struct FieldGoalView: View {
    let data: FieldGoalResponse

    var pct: Double { (data.fg_percentage) / 100.0 }

    var body: some View {
        ZStack {
            appGradient.ignoresSafeArea()

            VStack(spacing: 12) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.lakersGold)
                        .frame(width: 8, height: 8)
                    Text("Lakers")
                        .font(.graphik(13))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.9), lineWidth: 20)

                    Circle()
                        .trim(from: 0, to: CGFloat(pct))
                        .stroke(
                            Color.lakersGold,
                            style: StrokeStyle(lineWidth: 20, lineCap: .butt)
                        )
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(data.fg_percentage))%")
                        .font(.graphik(22))
                        .foregroundColor(.white)
                }
                .frame(width: 100, height: 100)

                Text("Field goal")
                    .font(.graphik(12))
                    .foregroundColor(.white.opacity(0.7)).padding(.top, 15)
            }
        }
    }
}

#Preview {
    FieldGoalView(
        data: FieldGoalResponse(
            game_id: 1,
            fg_percentage: 47.5
        )
    )
}
