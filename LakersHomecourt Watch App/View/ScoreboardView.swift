//
//  ScoreboardView.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI
import Combine

struct ScoreboardView: View {
    let data: ScoreboardResponse
    
    @State private var currentSeconds: Int = 0

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        ZStack {
            appGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Columnas por equipo
                HStack(alignment: .center, spacing: 0) {

                    // LAL
                    VStack(spacing: 4) {
                        TeamColumn(logoURL: data.lakers_logo)
                        Text(lakersAbbr)
                            .font(.graphik(15))
                            .foregroundStyle(Color.lakersGold)
                            .tracking(1.5)
                        Text("\(data.lakers_score)")
                            .font(.graphik(40))
                            .foregroundStyle(Color.lakersGold)
                            .shadow(color: Color.lakersGold.opacity(0.3), radius: 8)
                    }
                    .frame(maxWidth: .infinity)

                    Text(":")
                        .font(.graphik(40))
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.bottom, 6)

                    // Rival
                    VStack(spacing: 4) {
                        TeamColumn(logoURL: data.opposing_team_logo)
                        Text(opponentAbbr)
                            .font(.graphik(15))
                            .foregroundStyle(.white.opacity(0.70))
                            .tracking(1.5)
                        Text("\(data.opposing_score)")
                            .font(.graphik(40))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 8)

                Spacer()

                // Línea gold sutil abajo
                Rectangle()
                    .fill(Color.lakersGold.opacity(0.6))
                    .frame(width: 40, height: 1.5)
                    .padding(.bottom, 6)
                // Clock discreto arriba
                HStack(spacing: 4) {

                    Circle()
                        .fill(.red)
                        .frame(width: 7, height: 7)

                    Text("Q\(quarter) • \(gameClock)")
                        .font(.graphik(12))
                        .foregroundStyle(.white.opacity(0.70))
                }
                .padding(.top, 4)
            }
            .onAppear{
                currentSeconds = data.seconds_elapsed
            }
            .onReceive(timer){
                _ in currentSeconds += 1
            }
        }
    }

    var opponentAbbr: String {
        let words = data.opposing_team_name.split(separator: " ")
        return words.prefix(3).compactMap { $0.first }.map { String($0) }.joined()
    }

    var lakersAbbr: String {
        let words = data.lakers_name.split(separator: " ")
        return words.prefix(3).compactMap { $0.first }.map { String($0) }.joined()
    }
    
    var gameClock: String {

        let quarterDuration = 12 * 60

        let secondsIntoQuarter = currentSeconds % quarterDuration

        let remaining = max(
            quarterDuration - secondsIntoQuarter,
            0
        )

        let minutes = remaining / 60
        let seconds = remaining % 60

        return String(
            format: "%d:%02d",
            minutes,
            seconds
        )
    }

    var quarter: Int {

        min((currentSeconds / (12 * 60)) + 1, 4)
    }
}

#Preview {
    ScoreboardView(
        data: ScoreboardResponse(
            game_id: 1,
            lakers_name: "Los Angeles Lakers",
            lakers_logo: "https://upload.wikimedia.org/wikipedia/commons/3/3c/Los_Angeles_Lakers_logo.svg",
            lakers_score: 102,
            opposing_team_id: 2,
            opposing_team_name: "Golden State Warriors",
            opposing_team_logo: "https://upload.wikimedia.org/wikipedia/en/0/01/Golden_State_Warriors_logo.svg",
            opposing_score: 99,
            home: true,
            start_date: "2026-05-28",
            seconds_elapsed: 320,
            venue: "Crypto.com Arena",
            attended: 18997
        )
    )
}
