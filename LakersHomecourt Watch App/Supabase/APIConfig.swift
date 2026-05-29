//
//  APIConfig.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import Foundation
import Supabase

enum APIConfig {
    static let baseURL  = "https://ptbcoxaguvbwprxdundz.supabase.co/rest/v1"
    static let anonKey  = "sb_publishable_4EBAeMLhwGSLtPOq5K2D_Q_CJ0bSMIi"
    static let schema   = "simulacion_juego"
}


let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://ptbcoxaguvbwprxdundz.supabase.co")!,
    supabaseKey: APIConfig.anonKey
)
