//
//  CustomVoiceToggle.swift
//  isoWalk
//
//  Created by AnnElaine on 3/26/26.
//

import SwiftUI

struct CustomVoiceToggle: View {
    // Reads/Writes the user's preference automatically
    @AppStorage("useFemaleVoice") private var useFemaleVoice = true
    
    var body: some View {
        HStack(spacing: 0) {
            // Female Voice Button
            Button(action: { useFemaleVoice = true }) {
                Text("Female Voice")
                    .font(.custom("Inter-Medium", size: 14))
                    .foregroundColor(useFemaleVoice ? isoWalkColors.deepSpaceBlue : .white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .contentShape(Capsule())
            }
            
            // Male Voice Button
            Button(action: { useFemaleVoice = false }) {
                Text("Male Voice")
                    .font(.custom("Inter-Medium", size: 14))
                    .foregroundColor(!useFemaleVoice ? isoWalkColors.deepSpaceBlue : .white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .contentShape(Capsule())
            }
        }
        .padding(3)
        .background {
            GeometryReader { geo in
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .frame(width: geo.size.width / 2 - 3)
                    .offset(x: useFemaleVoice ? 3 : geo.size.width / 2)
                    .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.75), value: useFemaleVoice)
            }
        }
        .background(Color.black.opacity(0.15))
        .clipShape(Capsule())
        .padding(.horizontal, 40)
        
        // Audio playback preview
        .onChange(of: useFemaleVoice) { oldValue, newValue in
            let voicePrefix = newValue ? "Jacqueline" : "William"
            
            // Play the Starting Session mp3 as a preview so they can hear the voice!
            MusicPlayerService.shared.playVoiceCue(filename: "\(voicePrefix)-Greeting")
        }
    }
}

