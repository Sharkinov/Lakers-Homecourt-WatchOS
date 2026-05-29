//
//  ScrollingTicker.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI

struct ScrollingTicker: View {
    let text: String
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let repeated = String(repeating: "\(text)    ", count: 8)
            Text(repeated)
                .font(.graphik(10))
                .foregroundColor(.white)
                .fixedSize()
                .offset(x: offset)
                .onAppear {
                    offset = 0
                    withAnimation(.linear(duration: 9).repeatForever(autoreverses: false)) {
                        offset = -(geo.size.width * 4)
                    }
                }
        }
        .clipped()
    }
}

#Preview {
    ScrollingTicker(text: "No se que vaya aqui")
}
