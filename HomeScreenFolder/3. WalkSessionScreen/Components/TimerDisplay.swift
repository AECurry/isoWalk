//
//  TimerDisplay.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Displays the countdown timer and label.
//  Receives formatted time string and active state from parent — owns nothing.
//

import SwiftUI

struct TimerDisplay: View {
    let timeString: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(timeString)
                .font(.custom("Inter-Bold", size: 64))
                .foregroundColor(isoWalkColors.deepSpaceBlue)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: timeString)

            Text("Time Remaining")
                .font(.custom("Inter-Medium", size: 18))
                .foregroundColor(isoWalkColors.deepSpaceBlue)
                .opacity(0.8)
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        VStack(spacing: 32) {
            TimerDisplay(timeString: "21:00", isActive: true)
            TimerDisplay(timeString: "05:23", isActive: false)
        }
    }
}

