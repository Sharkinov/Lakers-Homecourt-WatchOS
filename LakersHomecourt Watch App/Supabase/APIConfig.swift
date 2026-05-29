//
//  APIConfig.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import Foundation

import Supabase

// Config

enum APIConfig {
    static let baseURL  = "https://ptbcoxaguvbwprxdundz.supabase.co/rest/v1"
    static let anonKey  = "TU_ANON_KEY"
    static let schema   = "simulacion_juego"
}

// Supabase Client

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://ptbcoxaguvbwprxdundz.supabase.co")!,
    supabaseKey: APIConfig.anonKey
)
