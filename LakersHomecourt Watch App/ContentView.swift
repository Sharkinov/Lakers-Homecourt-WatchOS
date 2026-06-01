//
//  ScoreboardView.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading{
                LoadingView()
                
            } else if let error = viewModel.error {
                ErrorView(message: error)
            } else if let sb = viewModel.scoreboard,
                      let fg = viewModel.fieldGoal,
                      let tc = viewModel.teamComparison {

                TabView {
                    ScoreboardView(data: sb)

                    FieldGoalView(
                        data: fg,
                        lakersName: sb.lakersAbbr
                    )

                    TeamComparisonView(
                        data: tc,
                        lakersName: sb.lakersAbbr,
                        opposingName: sb.opponentAbbr
                    )
                }
                .tabViewStyle(.page)

            } else if let nextGame = viewModel.nextGame {

                CountdownView(
                    nextGame: nextGame,
                    countdown: viewModel.countdownComponents
                )

            } else {

                LoadingView()
            }
        }
        .onAppear {
            viewModel.fetchAll()
            viewModel.subscribeToRealtime()
        }
        .onDisappear {
            viewModel.unsubscribe()
        }
    }
}

#Preview() {
    ContentView()
}
