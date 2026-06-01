//
//  TimeBlock.swift
//

import SwiftUI

struct TimeBlock: View {

    let value: Int
    let label: String

    var body: some View {

        VStack(spacing: 2) {

            Text(String(format: "%02d", value))
                .font(.graphik(16))
                .foregroundStyle(.white)
                .frame(width: 32)

            Text(label)
                .font(.graphik(9))
                .foregroundStyle(
                    .white.opacity(0.5)
                )
        }
    }
}

