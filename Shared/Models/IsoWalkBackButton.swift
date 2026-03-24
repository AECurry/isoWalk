//
//  IsoWalkBackButton.swift
//  isoWalk
//
//  Created by AnnElaine on 3/23/26.
//
//
//  SHARED COMPONENT
//  Universal back button for all screens to maintain exact top and leading placement.
//

import SwiftUI

struct IsoWalkBackButton: View {
    let theme: IsoWalkTheme
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.primaryIconColor)
                    // Generous padding for a better thumb hit-target
                    .padding(12)
                    // Ensures the invisible padded area is fully tapable
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // 12pt here + 12pt padding on the button = exact 24pt placement from the edge
            .padding(.leading, 12)
            
            Spacer()
        }
        // Forces the HStack to fill the width, anchoring the button firmly to the left
        .frame(maxWidth: .infinity)
        // Optical adjustment to align perfectly with the safe area
        .padding(.top, -8)
    }
}

