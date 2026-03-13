import Foundation
import Combine
import Supabase

// Config

enum APIConfig {
    static let baseURL  = "https://ptbcoxaguvbwprxdundz.supabase.co/rest/v1"
    static let anonKey  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0YmNveGFndXZid3ByeGR1bmR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzNDMzOTQsImV4cCI6MjA4ODkxOTM5NH0.gPMQ9zMFJZafkgQGjaoHBaacU787LhLpENcRMHFXpH8"
    static let schema   = "simulacion_juego"
}

// Supabase Client

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://ptbcoxaguvbwprxdundz.supabase.co")!,
    supabaseKey: APIConfig.anonKey
)

// Response Models

struct ScoreboardResponse: Codable {
    let game_id: Int
    let current_quarter: Int
    let current_quarter_start: String?
    let game_end_time: String?
    let defense: Bool
    let lakers_logo: String     
    let opposing_team_name: String
    let opposing_team_logo: String
    let lakers_score: Int
    let opposing_score: Int
    let lakers_team_name: String
}

struct FieldGoalResponse: Codable {
    let game_id: Int
    let fg_percentage: Double
}

struct TeamComparisonResponse: Codable {
    let game_id: Int
    let lakers_rebounds: Int
    let opposing_rebounds: Int
    let lakers_assists: Int
    let opposing_assists: Int
    let lakers_steals: Int
    let opposing_steals: Int
}

// NetworkManager

class NetworkManager: ObservableObject {

    @Published var scoreboard: ScoreboardResponse?
    @Published var fieldGoal: FieldGoalResponse?
    @Published var teamComparison: TeamComparisonResponse?
    @Published var isLoading = false
    @Published var error: String?

    private var channel: RealtimeChannelV2?

    private var headers: [String: String] {
        [
            "apikey":         APIConfig.anonKey,
            "Authorization":  "Bearer \(APIConfig.anonKey)",
            "Accept-Profile": APIConfig.schema
        ]
    }

    // Fetch

    func fetchAll() {
        isLoading = true
        error = nil

        Task {
            async let sb = fetch(ScoreboardResponse.self,     from: "v_scoreboard")
            async let fg = fetch(FieldGoalResponse.self,      from: "v_fieldgoal")
            async let tc = fetch(TeamComparisonResponse.self, from: "v_team_comparison")

            let (sbResult, fgResult, tcResult) = await (sb, fg, tc)

            await MainActor.run {
                self.scoreboard     = sbResult?.first
                self.fieldGoal      = fgResult?.first
                self.teamComparison = tcResult?.first
                self.isLoading      = false
            }
        }
    }

    private func fetch<T: Codable>(_ type: T.Type, from endpoint: String) async -> [T]? {
        guard let url = URL(string: "\(APIConfig.baseURL)/\(endpoint)") else { return nil }

        var request = URLRequest(url: url)
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            await MainActor.run { self.error = error.localizedDescription }
            return nil
        }
    }

    // Realtime

    func subscribeToRealtime() {
        Task {
            let channel = await supabase.realtimeV2.channel("game-updates")

            let gameChanges = await channel.postgresChange(
                AnyAction.self,
                schema: APIConfig.schema,
                table: "game"
            )

            let statsChanges = await channel.postgresChange(
                AnyAction.self,
                schema: APIConfig.schema,
                table: "team_player_stats"
            )

            await channel.subscribe()
            self.channel = channel

            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    for await _ in gameChanges { self.fetchAll() }
                }
                group.addTask {
                    for await _ in statsChanges { self.fetchAll() }
                }
            }
        }
    }

    func unsubscribe() {
        Task {
            await channel?.unsubscribe()
        }
    }

    // Game Clock

    func gameClock(from quarterStart: String?) -> String {
        guard let quarterStart else { return "--:--" }

        // Convierte "2026-03-11 20:35:00+00" → "2026-03-11T20:35:00+00:00"
        let normalized = quarterStart
            .replacingOccurrences(of: " ", with: "T")
            .replacingOccurrences(of: "+00:00:00", with: "+00:00")
            .replacingOccurrences(of: "+00", with: "+00:00")

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let start = formatter.date(from: normalized) else { return "--:--" }

        let elapsed = Date().timeIntervalSince(start)
        let quarterDuration: TimeInterval = 12 * 60
        let remaining = max(quarterDuration - elapsed, 0)

        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
