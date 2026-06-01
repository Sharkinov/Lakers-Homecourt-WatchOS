//
//  GameViewModel.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 29/05/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class GameViewModel: ObservableObject {

    @Published var scoreboard: ScoreboardResponse?
    @Published var fieldGoal: FieldGoalResponse?
    @Published var teamComparison: TeamComparisonResponse?

    @Published var isLoading = false
    @Published var error: String?

    private let service = GameService()
    
    func fetchAll() {

        isLoading = true
        error = nil

        Task {

            do {

                let scoreboard = try await service.fetchScoreboard()

                let fieldGoal = try await service.fetchFieldGoal()

                let comparison = try await service.fetchTeamComparison()

                self.scoreboard = scoreboard
                self.fieldGoal = fieldGoal
                self.teamComparison = comparison

                self.isLoading = false

            } catch {

                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }


    func subscribeToRealtime() {

        service.subscribeToRealtime {

            await MainActor.run {
                self.fetchAll()
            }
        }
    }

    func unsubscribe() {

        service.unsubscribe()
    }

    func gameClock(
        from secondsElapsed: Int
    ) -> String {

        let quarterDuration = 12 * 60

        let remaining = max(
            quarterDuration - secondsElapsed,
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
}

extension ScoreboardResponse {

    var lakersAbbr: String {
        let words = lakers_name.split(separator: " ")
        return words.prefix(3)
            .compactMap(\.first)
            .map(String.init)
            .joined()
    }

    var opponentAbbr: String {
        let words = opposing_team_name.split(separator: " ")
        return words.prefix(3)
            .compactMap(\.first)
            .map(String.init)
            .joined()
    }
}
