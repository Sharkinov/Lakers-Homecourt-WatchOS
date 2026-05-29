//
//  LoadingView.swift
//  LakersHomecourt Watch App
//
//  Created by Cielo Maria Vega Godoy on 28/05/26.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            appGradient.ignoresSafeArea()
            ProgressView().tint(.lakersGold)
        }
    }
}

#Preview {
    LoadingView()
}
