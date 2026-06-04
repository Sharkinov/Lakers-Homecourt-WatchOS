//
//  NotificationSettingsView.swift
//  LakersHomecourt Watch App
//
//  Created by AGRM on 03/06/26.
//

import SwiftUI

struct NotificationSettingsView: View {
    
    @AppStorage("notif_game_start") private var gameStart: Bool = true
    @AppStorage("notif_quarter_change") private var quarterChange: Bool = true
    @AppStorage("notif_game_end") private var gameEnd: Bool = true
    @AppStorage("notif_lakers_score") private var lakersScore: Bool = true
    @AppStorage("notif_lakers_run") private var lakersRun: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Notifications")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                Toggle("Game start", isOn: $gameStart)
                Toggle("Quarter start", isOn: $quarterChange)
                Toggle("Game end", isOn: $gameEnd)
                Toggle("Lakers score", isOn: $lakersScore)
                Toggle("Lakers on a run", isOn: $lakersRun)
            }
            .padding()
        }
    }
}

#Preview {
    NotificationSettingsView()
}
