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
                .foregroundColor(.white.opacity(0.25))
                .padding(.top, 32)

            Text("No Music Selected")
                .font(.custom("Inter-Bold", size: 18))
                .foregroundColor(.white)

            Text("The interval timer will still guide your pace with chimes and voice cues.")
                .font(.custom("Inter-Regular", size: 15))
                .foregroundColor(.white.opacity(0.60))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

#Preview {
    ZStack {
        isoWalkColors.balticBlue.ignoresSafeArea()
        NoMusicTab()
    }
}

