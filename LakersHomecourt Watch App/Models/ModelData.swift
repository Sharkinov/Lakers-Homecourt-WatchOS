//
//  ModelData.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import Foundation

struct ScoreboardResponse: Codable, Sendable {
    let game_id: Int
    let lakers_name: String
    let lakers_logo: String
    let lakers_score: Int
    let opposing_team_id: Int
    let opposing_team_name: String
    let opposing_team_logo: String
    let opposing_score: Int
    let home: Bool
    let start_date: String
    let seconds_elapsed: Int
    let venue: String
    let attended: Int
}

struct FieldGoalResponse: Codable, Sendable {
    let game_id: Int
    let fg_percentage: Double
}

struct TeamComparisonResponse: Codable, Sendable {
    let game_id: Int
    let lakers_rebounds: Int
    let opposing_rebounds: Int
    let lakers_assists: Int
    let opposing_assists: Int
    let lakers_steals: Int
    let opposing_steals: Int
}

struct NextGameResponse: Codable, Sendable {
    let game_id: Int
    let opposing_team_name: String
    let opposing_team_logo: String
    let start_date: String
}
