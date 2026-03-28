//
//  NoMusicTab.swift
//  isoWalk
//
//  Created by AnnElaine on 3/12/26.
//
//
//  Tab content for "No Music" mode.
//  Explains that interval timer will still work with chimes and voice cues.
//

import SwiftUI

struct NoMusicTab: View {
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "speaker.slash.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 40)
            
            Text("No Music Selected")
                .font(.custom("Inter-SemiBold", size: 18))
                .foregroundColor(.white)
            
            Text("The interval timer will still guide your pace with chimes and voice cues.")
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // 👉 Dropping in the reusable CustomVoiceToggle!
            CustomVoiceToggle()
                .padding(.top, 16)
            
            Spacer(minLength: 40)
        }
    }
}

#Preview {
    ZStack {
        isoWalkColors.balticBlue.ignoresSafeArea()
        NoMusicTab()
    }
}

