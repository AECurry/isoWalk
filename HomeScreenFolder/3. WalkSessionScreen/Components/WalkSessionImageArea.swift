//
//  WalkSessionImageArea.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONET — dumb child.
//  Displays the selected theme image statically during a walk session.
//  Static (no animation) — two animations already exist on this screen.
//  - FIXED: Added support for static layered themes and video fallbacks.
//

import SwiftUI

struct WalkSessionImageArea: View {
    let theme: IsoWalkTheme

    var body: some View {
        ZStack {
            switch theme.animationType {
            case .layeredAnimation(let bgImage, let overlayImage, _):
                ZStack {
                    Image(bgImage)
                        .resizable()
                        .scaledToFit()
                    
                    Image(overlayImage)
                        .resizable()
                        .scaledToFit()
                        .opacity(0.7)
                }
                
            case .video(_, let fallback):
                Image(fallback)
                    .resizable()
                    .scaledToFit()
                
            default:
                Image(theme.mainImageName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: AnimatedImageSize.medium.dimension,
               height: AnimatedImageSize.medium.dimension)
        // Using -12 top padding to pull it up toward the back button,
        // matching the "Set Up" screen's tight vertical spacing.
        .padding(.top, 0)
        .padding(.bottom, 8)
    }
}

