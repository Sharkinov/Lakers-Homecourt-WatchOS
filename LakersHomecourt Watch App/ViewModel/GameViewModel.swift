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

    @Published var nextGame: NextGameResponse?
    @Published var countdownComponents: CountdownComponents = .zero

    private var countdownTimer: Timer?

    private let service = GameService()

    func fetchAll() {

        isLoading = true
        error = nil

        Task {

            do {

                let scoreboard  = try await service.fetchScoreboard()
                let fieldGoal   = try await service.fetchFieldGoal()
                let comparison  = try await service.fetchTeamComparison()
                let next        = try await service.fetchNextGame()

                self.scoreboard     = scoreboard
                self.fieldGoal      = fieldGoal
                self.teamComparison = comparison
                self.nextGame       = next

                self.isLoading = false

                if next != nil {
                    self.startCountdownTimer()
                } else {
                    self.stopCountdownTimer()
                }

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

    func gameClock(from secondsElapsed: Int) -> String {

        let quarterDuration = 12 * 60
        let remaining = max(quarterDuration - secondsElapsed, 0)
        let minutes = remaining / 60
        let seconds = remaining % 60

        return String(format: "%d:%02d", minutes, seconds)
    }

    func startCountdownTimer() {
        stopCountdownTimer()
        updateCountdown()
        countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true,
            block: { @Sendable [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.updateCountdown()
                }
            }
        )
    }

    func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    private func updateCountdown() {

        guard let next = nextGame else {
            countdownComponents = .zero
            return
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let targetDate: Date? = formatter.date(from: next.start_date) ?? {
            formatter.formatOptions = [.withInternetDateTime]
            return formatter.date(from: next.start_date)
        }()

        guard let targetDate else {
            countdownComponents = .zero
            return
        }

        let diff = Int(targetDate.timeIntervalSinceNow)

        guard diff > 0 else {
            countdownComponents = .zero
            stopCountdownTimer()
            fetchAll()
            return
        }

        countdownComponents = CountdownComponents(
            days:    diff / 86_400,
            hours:   (diff % 86_400) / 3_600,
            minutes: (diff % 3_600) / 60,
            seconds: diff % 60
        )
    }

    nonisolated func cleanup() {
        Task { @MainActor in
            self.stopCountdownTimer()
        }
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

struct CountdownComponents {
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int

    static let zero = CountdownComponents(
        days: 0, hours: 0, minutes: 0, seconds: 0
    )

    var isZero: Bool {
        days == 0 && hours == 0 && minutes == 0 && seconds == 0
    }
}
