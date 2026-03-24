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
            }
            .buttonStyle(.plain)
            .padding(.leading, 24) // Exact placement from the leading side
            
            Spacer()
        }
        // Exact placement from the top
        .padding(.top, -8)
    }
}

