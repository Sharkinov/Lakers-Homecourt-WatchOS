//
//  LegendDot.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI

struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label)
                .font(.graphik(12))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    LegendDot(color: Color.red, label: "HELLO")
}
