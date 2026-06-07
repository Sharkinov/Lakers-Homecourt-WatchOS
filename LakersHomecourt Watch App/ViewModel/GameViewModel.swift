//
//  GameViewModel.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 29/05/26.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

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
    private var pollingTimer: Timer?
    private var lastKnownQuarter: Int = -1
    private var lastKnownGameEndTime: String? = nil
    private var lastKnownLakersScore: Int = -1
    private var lastKnownOpponentScore: Int = -1
    private var lakersRunScore: Int = 0
    private var opponentScoreDuringRun: Int = 0

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

                if let scoreboard = scoreboard {
                    self.checkScoreNotifications(newScore: scoreboard)
                }

                self.scoreboard     = scoreboard
                self.fieldGoal      = fieldGoal
                self.teamComparison = comparison
                self.nextGame       = next
                self.isLoading      = false

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

    // MARK: - Score Notifications

    private func checkScoreNotifications(newScore: ScoreboardResponse) {
        guard lastKnownLakersScore != -1 else {
            lastKnownLakersScore = newScore.lakers_score
            lastKnownOpponentScore = newScore.opposing_score
            lakersRunScore = newScore.lakers_score
            opponentScoreDuringRun = newScore.opposing_score
            return
        }

        let center = UNUserNotificationCenter.current()
        let scorePref = UserDefaults.standard.object(forKey: "notif_lakers_score") as? Bool ?? true
        let runPref = UserDefaults.standard.object(forKey: "notif_lakers_run") as? Bool ?? true

        if newScore.lakers_score > lastKnownLakersScore && scorePref {
            let content = UNMutableNotificationContent()
            content.title = "Lakers score"
            content.body = "LAL \(newScore.lakers_score) - \(newScore.opponentAbbr) \(newScore.opposing_score)"
            content.sound = .default
            Task { try? await center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)) }
        }

        if newScore.opposing_score > lastKnownOpponentScore {
            lakersRunScore = newScore.lakers_score
            opponentScoreDuringRun = newScore.opposing_score
        }

        let lakersRunPoints = newScore.lakers_score - lakersRunScore
        if lakersRunPoints >= 5 && newScore.opposing_score == opponentScoreDuringRun && runPref {
            let content = UNMutableNotificationContent()
            content.title = "Lakers on a run"
            content.body = "\(lakersRunPoints) unanswered — LAL \(newScore.lakers_score) - \(newScore.opponentAbbr) \(newScore.opposing_score)"
            content.sound = .default
            Task { try? await center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)) }
            lakersRunScore = newScore.lakers_score
            opponentScoreDuringRun = newScore.opposing_score
        }

        lastKnownLakersScore = newScore.lakers_score
        lastKnownOpponentScore = newScore.opposing_score
    }

    // MARK: - Local Notifications Polling

    func startPolling() {
        stopPolling()
        pollGameStatus()
        pollingTimer = Timer.scheduledTimer(
            withTimeInterval: 5.0,
            repeats: true,
            block: { @Sendable [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.pollGameStatus()
                }
            }
        )
    }

    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    private func pollGameStatus() {
        Task {
            guard let status = try? await service.fetchGameStatus() else {
                print("Polling: failed to fetch game status")
                return
            }

            print("Polling: quarter=\(status.current_quarter) lastKnown=\(lastKnownQuarter)")

            let center = UNUserNotificationCenter.current()
            let gameStartPref = UserDefaults.standard.object(forKey: "notif_game_start") as? Bool ?? true
            let quarterPref   = UserDefaults.standard.object(forKey: "notif_quarter_change") as? Bool ?? true
            let gameEndPref   = UserDefaults.standard.object(forKey: "notif_game_end") as? Bool ?? true

            if lastKnownQuarter == -1 {
                lastKnownQuarter = status.current_quarter
                lastKnownGameEndTime = status.game_end_time
                return
            }

            if status.current_quarter == 1 && lastKnownQuarter == 0 && gameStartPref {
                let content = UNMutableNotificationContent()
                content.title = "Game started"
                content.body = "Lakers vs \(scoreboard?.opponentAbbr ?? "OPP") — Live now"
                content.sound = .default
                try? await center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
            } else if status.current_quarter != lastKnownQuarter && status.current_quarter > 1 && quarterPref {
                let content = UNMutableNotificationContent()
                content.title = "Q\(status.current_quarter) started"
                content.body = "LAL \(scoreboard?.lakers_score ?? 0) - \(scoreboard?.opponentAbbr ?? "OPP") \(scoreboard?.opposing_score ?? 0)"
                content.sound = .default
                try? await center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
            }

            if status.game_end_time != nil && lastKnownGameEndTime == nil && gameEndPref {
                let content = UNMutableNotificationContent()
                content.title = status.won ? "Lakers win" : "Lakers lose"
                content.body = "Final: LAL \(scoreboard?.lakers_score ?? 0) - \(scoreboard?.opponentAbbr ?? "OPP") \(scoreboard?.opposing_score ?? 0)"
                content.sound = .default
                try? await center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
            }

            // Check score notifications
            if let newScoreboard = try? await service.fetchScoreboard() {
                self.checkScoreNotifications(newScore: newScoreboard)
                self.scoreboard = newScoreboard
            }

            lastKnownQuarter = status.current_quarter
            lastKnownGameEndTime = status.game_end_time
        }
    }

    // MARK: - Realtime

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

    // MARK: - Game Clock

    func gameClock(from secondsElapsed: Int) -> String {
        let quarterDuration = 12 * 60
        let remaining = max(quarterDuration - secondsElapsed, 0)
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Countdown Timer

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
            self.stopPolling()
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
