//
//  CountdownView.swift
//  LakersHomecourt Watch App
//

import SwiftUI

struct CountdownView: View {

    let nextGame: NextGameResponse
    let countdown: CountdownComponents

    var body: some View {

        ZStack {
            appGradient.ignoresSafeArea()

            VStack {

                Text("NEXT GAME")
                    .font(.graphik(10))
                    .foregroundStyle(
                        .white.opacity(0.5)
                    )
                    .tracking(1.5)

                AsyncImage(
                    url: URL(
                        string: nextGame.opposing_team_logo
                    )
                ) { image in

                    image
                        .resizable()
                        .scaledToFit()

                } placeholder: {

                    ProgressView()
                }
                .frame(
                    width: 55,
                    height: 55
                )

                Text(
                    abbreviation(
                        from: nextGame.opposing_team_name
                    )
                )
                .font(.graphik(16))
                .foregroundStyle(.white).padding(.bottom)

                HStack(spacing: 6) {

                    TimeBlock(
                        value: countdown.days,
                        label: "D"
                    )

                    TimeBlock(
                        value: countdown.hours,
                        label: "H"
                    )

                    TimeBlock(
                        value: countdown.minutes,
                        label: "M"
                    )

                    TimeBlock(
                        value: countdown.seconds,
                        label: "S"
                    )
                }
                Rectangle()
                    .fill(Color.lakersGold.opacity(0.6))
                    .frame(width: 40, height: 1.5)
                    .padding(.vertical, 6)
                Text("vs Lakers")
                    .font(.graphik(11))
                    .foregroundStyle(
                        .white.opacity(0.7)
                    )            }
        }
    }

    private func abbreviation(
        from teamName: String
    ) -> String {

        let words = teamName.split(separator: " ")

        return words
            .prefix(3)
            .compactMap(\.first)
            .map(String.init)
            .joined()
    }
}

#Preview {
    CountdownView(
        nextGame: NextGameResponse(
            game_id: 1,
            opposing_team_name: "Golden State Warriors",
            opposing_team_logo: "https://ptbcoxaguvbwprxdundz.supabase.co/storage/v1/object/public/team-logos/OklahomaCity.png",
            start_date: "2026-06-01T12:00:00.000Z"
        ),
        countdown: CountdownComponents(
            days: 3,
            hours: 12,
            minutes: 44,
            seconds: 18
        )
    )
}
