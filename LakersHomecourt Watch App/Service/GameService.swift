//
//  GameService.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 29/05/26.
//

import Foundation
import Supabase

final class GameService {

    private var channel: RealtimeChannelV2?

    private var headers: [String: String] {
        [
            "apikey": APIConfig.anonKey,
            "Authorization": "Bearer \(APIConfig.anonKey)",
            "Accept-Profile": APIConfig.schema
        ]
    }


    private func fetch<T: Codable>(
        _ type: T.Type,
        from endpoint: String
    ) async throws -> [T] {

        guard let url = URL(
            string: "\(APIConfig.baseURL)/\(endpoint)"
        ) else {
            return []
        }

        var request = URLRequest(url: url)

        headers.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }

        let (data, _) = try await URLSession.shared.data(for: request)

        return try JSONDecoder().decode([T].self, from: data)
    }


    func fetchScoreboard() async throws -> ScoreboardResponse? {

        try await fetch(
            ScoreboardResponse.self,
            from: "v_marcador_activo"
        ).first
    }

    func fetchFieldGoal() async throws -> FieldGoalResponse? {

        try await fetch(
            FieldGoalResponse.self,
            from: "v_fieldgoal"
        ).first
    }

    func fetchTeamComparison() async throws -> TeamComparisonResponse? {

        try await fetch(
            TeamComparisonResponse.self,
            from: "v_team_comparison"
        ).first
    }


    func subscribeToRealtime(
        onGameUpdate: @escaping () async -> Void
    ) {

        Task {

            let channel = supabase.realtimeV2.channel(
                "game-updates"
            )

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

                print(
                    "Realtime subscription error:",
                    error
                )

                return
            }

            await withTaskGroup(of: Void.self) { group in

                group.addTask {

                    for await _ in gameChanges {
                        await onGameUpdate()
                    }
                }

                group.addTask {

                    for await _ in statsChanges {
                        await onGameUpdate()
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
}
