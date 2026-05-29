import Foundation
import Combine
import Supabase

@MainActor
class NetworkManager: ObservableObject {

    @Published var scoreboard: ScoreboardResponse?
    @Published var fieldGoal: FieldGoalResponse?
    @Published var teamComparison: TeamComparisonResponse?
    @Published var isLoading = false
    @Published var error: String?

    private var channel: RealtimeChannelV2?

    private var headers: [String: String] {
        [
            "apikey": APIConfig.anonKey,
            "Authorization": "Bearer \(APIConfig.anonKey)",
            "Accept-Profile": APIConfig.schema
        ]
    }

    // Fetch

    func fetchAll() {

        isLoading = true
        error = nil

        Task {

            let sbResult = await fetch(
                ScoreboardResponse.self,
                from: "v_marcador_activo"
            )

            let fgResult = await fetch(
                FieldGoalResponse.self,
                from: "v_fieldgoal"
            )

            let tcResult = await fetch(
                TeamComparisonResponse.self,
                from: "v_team_comparison"
            )

            self.scoreboard = sbResult?.first
            self.fieldGoal = fgResult?.first
            self.teamComparison = tcResult?.first
            self.isLoading = false
        }
    }

    private func fetch<T: Codable>(
        _ type: T.Type,
        from endpoint: String
    ) async -> [T]? {

        guard let url = URL(string: "\(APIConfig.baseURL)/\(endpoint)") else {
            return nil
        }

        var request = URLRequest(url: url)

        headers.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            return try JSONDecoder().decode([T].self, from: data)

        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    // Realtime

    func subscribeToRealtime() {

        Task {

            let channel = supabase.realtimeV2.channel("game-updates")

            let gameChanges = channel.postgresChange(
                AnyAction.self,
                schema: APIConfig.schema,
                table: "game"
            )

            let statsChanges = channel.postgresChange(
                AnyAction.self,
                schema: APIConfig.schema,
                table: "team_player_stats"
            )

            do {

                try await channel.subscribeWithError()

                self.channel = channel

            } catch {

                print("Realtime subscription error:", error)
                return
            }

            await withTaskGroup(of: Void.self) { group in

                group.addTask {

                    for await _ in gameChanges {
                        await self.fetchAll()
                    }
                }

                group.addTask {

                    for await _ in statsChanges {
                        await self.fetchAll()
                    }
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

    func gameClock(from secondsElapsed: Int) -> String {

        let quarterDuration = 12 * 60
        let remaining = max(quarterDuration - secondsElapsed, 0)

        let minutes = remaining / 60
        let seconds = remaining % 60

        return String(format: "%d:%02d", minutes, seconds)
    }
}
