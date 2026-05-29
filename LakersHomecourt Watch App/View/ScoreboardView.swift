//
//  ScoreboardView.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI

struct ScoreboardView: View {
    let data: ScoreboardResponse
    let gameClock: String

    var body: some View {
        ZStack(alignment: .bottom) {
            appGradient.ignoresSafeArea()

            VStack(spacing: 0) {

                // Status bar
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 7, height: 7)
                    Text("\(gameClock)")
                        .font(.graphik(13))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)

                // Gold divider
                Rectangle()
                    .fill(Color.lakersGold)
                    .frame(height: 1.5)
                    .padding(.horizontal, 12)
                    .padding(.top, 5)

                // Logos
                HStack(alignment: .top) {
                    TeamColumn(name: lakersAbbr, logoURL: data.lakers_logo)
                    Spacer()
                    TeamColumn(name: opponentAbbr, logoURL: data.opposing_team_logo)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // Scores
                HStack {
                    Text("\(data.lakers_score)")
                        .font(.graphik(25))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(data.opposing_score)")
                        .font(.graphik(25))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 2)

                Spacer(minLength: 4)

                // Defense ticker
                /*if data.defense {
                    ZStack {
                        Color(red: 0.78, green: 0.10, blue: 0.10)
                        ScrollingTicker(text: "DEFENSE")
                    }
                    .frame(height: 20)
                }*/
            }
        }
    }

    // e.g. "Golden State Warriors" → "GSW"
    var opponentAbbr: String {
        let words = data.opposing_team_name.split(separator: " ")
        return words.prefix(3).compactMap { $0.first }.map { String($0) }.joined()
    }
    
    var lakersAbbr: String {
        let words = data.lakers_name.split(separator: " ")
        return words.prefix(3).compactMap { $0.first }.map { String($0) }.joined()
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
        ),
        gameClock: "6:40"
    )
}
