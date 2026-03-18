//
//  WalkSetUpHeader.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Back button, logo, and smaller animated image for the setup screen.
//  Receives theme and back callback from parent — owns nothing else.
//  - FIXED: Removed outdated `size` argument to match the updated SetUpImageArea
//

import SwiftUI

struct WalkSetUpHeader: View {
    let theme: IsoWalkTheme
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Back Button Row
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                    // Standardize padding for a better hit target
                        .padding(12)
                }
                
                .padding(.leading, 56)
                
                Spacer()
            }
            // Use a small amount of padding; the Safe Area handles the notch
            .padding(.top, -24)
            
            // 2. Logo
            Image("isoWalkLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .padding(.top, -16) // Negative padding pulls the logo up closer to the back button
            
            // 3. Theme Image (Fixed: SetUpImageArea now sizes itself)
            SetUpImageArea(theme: theme)
                .padding(.top, -12)
        }
    }
}

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        WalkSetUpHeader(
            theme: IsoWalkThemes.all[0],
            onBack: {}
        )
    }
}

