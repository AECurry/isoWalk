//
//  WalkSessionHeader.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Back chevron and isoWalk logo for the walk session screen.
//  Receives back callback from parent — owns nothing else.
//

import SwiftUI

struct WalkSessionHeader: View {
    // 1. Match the parameter setup of WalkSetUpHeader
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
                        // Standardize padding for better hit target
                        .padding(12)
                }
                .buttonStyle(.plain)
                .padding(.leading, 16) // Solid 8-point grid alignment
                
                Spacer()
            }
            // Pull it up into the notch area exactly like Setup
            .padding(.top, -24)
            
        }
    }
}
