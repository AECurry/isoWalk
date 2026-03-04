//
//  LetsGoButton.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Full-width gradient button matching Figma design.
//  Receives isEnabled and action from parent — owns nothing.
//

import SwiftUI

struct LetsGoButton: View {
    @AppStorage("letsGoButtonWidth") private var width: Double = 200
    @AppStorage("letsGoButtonHeight") private var height: Double = 64
    @AppStorage("letsGoButtonCornerRadius") private var cornerRadius: Double = 32

    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Let's Go")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .background(
                    Capsule()
                        .fill(isEnabled ? isoWalkColors.gradientBlue : LinearGradient(
                            colors: [isoWalkColors.balticBlue.opacity(0.5),
                                     isoWalkColors.deepSpaceBlue.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .shadow(color: isoWalkColors.deepSpaceBlue.opacity(isEnabled ? 0.4 : 0.1),
                                radius: 8, x: 0, y: 4)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
        .padding(.bottom, 32)
    }
}

#Preview {
    VStack(spacing: 20) {
        LetsGoButton(isEnabled: true, action: {})
        LetsGoButton(isEnabled: false, action: {})
    }
    .padding()
    .background(isoWalkColors.adaptiveBackground)
}

