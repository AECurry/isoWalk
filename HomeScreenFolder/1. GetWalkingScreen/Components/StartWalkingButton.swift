//
//  StartWalkingButton.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI

struct StartWalkingButton: View {
    @AppStorage("buttonWidth") private var width: Double = 200
    @AppStorage("buttonHeight") private var height: Double = 64
    @AppStorage("buttonCornerRadius") private var cornerRadius: Double = 32
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {  // USE action - not sessionManager
            Text("Start Walking")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .background(
                    Capsule()
                        .fill(isoWalkColors.gradientBlue)
                        .shadow(color: isoWalkColors.deepSpaceBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.bottom, 32)
    }
}

