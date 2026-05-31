//
//  TeamColumn.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI

struct TeamColumn: View {
    let logoURL: String

    var body: some View {
        VStack(spacing: 3) {
            AsyncImage(url: URL(string: logoURL)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFit()
                default:
                    Circle()
                        .fill(Color.white.opacity(0.12))
                }
            }
            .frame(width: 30, height: 30)
        }
    }
}

#Preview {
    TeamColumn(logoURL: "")
}
