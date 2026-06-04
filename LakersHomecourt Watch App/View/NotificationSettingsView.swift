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
        ZStack {
            appGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    
                    Text("NOTIFICATIONS")
                        .font(.graphik(10))
                        .foregroundStyle(.white.opacity(0.5))
                        .tracking(1.5)
                        .padding(.bottom, 4)
                    
                    NotifToggle(label: "Game start", isOn: $gameStart)
                    NotifToggle(label: "Quarter start", isOn: $quarterChange)
                    NotifToggle(label: "Game end", isOn: $gameEnd)
                    NotifToggle(label: "Lakers score", isOn: $lakersScore)
                    NotifToggle(label: "Lakers on a run", isOn: $lakersRun)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
    }
}

private struct NotifToggle: View {
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.graphik(13))
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.lakersGold)
        }
    }
}

#Preview {
    NotificationSettingsView()
}
