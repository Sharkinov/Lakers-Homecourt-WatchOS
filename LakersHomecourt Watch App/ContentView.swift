//
//  ScoreboardView.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var network = NetworkManager()

    var body: some View {
        Group {
            if network.isLoading{
                LoadingView()
                
            } else if let error = network.error {
                ErrorView(message: error)
            } else if let sb = network.scoreboard,
                      let fg = network.fieldGoal,
                      let tc = network.teamComparison {
                TabView {
                    ScoreboardView(
                        data: sb,
                        gameClock: network.gameClock(from: sb.seconds_elapsed))
                    FieldGoalView(data: fg)
                    TeamComparisonView(data: tc)
                }
                .tabViewStyle(.page)
            } else {
                LoadingView()
            }
        }
        .onAppear {
            network.fetchAll()
            network.subscribeToRealtime()
        }
        .onDisappear {
            network.unsubscribe()
        }
    }
}

#Preview() {
    ContentView()
}
