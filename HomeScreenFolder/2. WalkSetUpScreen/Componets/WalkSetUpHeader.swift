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
            // Back Button Row
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(theme.primaryIconColor)
                    // Standardize padding for a better hit target
                        .padding(12)
                }
                
                .padding(.leading, 16)
                
                Spacer()
            }
            // Use a small amount of padding; the Safe Area handles the notch
            .padding(.top, -24)
            
            
            // Theme Image (Fixed: SetUpImageArea now sizes itself)
            WalkSetUpImageArea(theme: theme)
                .padding(.top, -12)
        }
    }
}

