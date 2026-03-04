//
//  PlaybackControls.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Stop and Play/Pause buttons for the walk session screen.
//  Receives timer state and action callbacks from parent — owns nothing.
//

import SwiftUI

struct PlaybackControls: View {
    let timerState: TimerState
    let onPlayPause: () -> Void
    let onStop: () -> Void

    private var isPlaying: Bool { timerState == .running }

    var body: some View {
        HStack(spacing: 40) {
            ControlButton(
                iconName: "stop.fill",
                color: isoWalkColors.brandy,
                action: onStop
            )
            ControlButton(
                iconName: isPlaying ? "pause.fill" : "play.fill",
                color: isoWalkColors.forestGreen,
                action: onPlayPause
            )
        }
        .padding(.vertical, 16)
    }
}

struct ControlButton: View {
    let iconName: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 70, height: 70)
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)

                Image(systemName: iconName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: iconName)
    }
}

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        VStack(spacing: 32) {
            PlaybackControls(timerState: .stopped, onPlayPause: {}, onStop: {})
            PlaybackControls(timerState: .running, onPlayPause: {}, onStop: {})
            PlaybackControls(timerState: .paused, onPlayPause: {}, onStop: {})
        }
    }
}

