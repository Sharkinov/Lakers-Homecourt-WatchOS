//
//  TeamColumn.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI

struct TeamColumn: View {
    let name: String
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
                        .overlay(
                            Text(name)
                                .font(.graphik(10))
                                .foregroundColor(.white)
                        )
                }
            }
            .frame(width: 52, height: 52)

            Text(name)
                .font(.graphik(14))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    TeamColumn(name: "Warriors", logoURL: "")
}
