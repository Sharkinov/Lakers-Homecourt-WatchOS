//
//  ErrorView.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    var body: some View {
        ZStack {
            appGradient.ignoresSafeArea()
            Text(message)
                .font(.graphik(11))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

#Preview {
    ErrorView(message: "Error")
}
