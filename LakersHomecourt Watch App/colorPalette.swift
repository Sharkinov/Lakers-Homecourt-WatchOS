//
//  colorPalette.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import Foundation
import SwiftUI

extension Color {
    static let lakersGold  = Color(red: 253/255, green: 185/255, blue: 39/255)
    static let gswGray     = Color(red: 180/255, green: 180/255, blue: 185/255)
    static let gradientTop = Color(hex: "2B1842")
    static let gradientBot = Color(hex: "542581")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// Colors & Gradient
var appGradient: LinearGradient {
    LinearGradient(
        colors: [.gradientTop, .gradientBot],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Font {
    static func graphik(_ size: CGFloat) -> Font {
        .custom("Graphik-Regular", size: size)
    }
}
