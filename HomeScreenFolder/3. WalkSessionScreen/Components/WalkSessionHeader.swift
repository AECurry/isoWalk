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
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 1. Back Button Row
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                        .padding(12)
                }
                .buttonStyle(.plain)
                .padding(.leading, 56)

                Spacer()
            }
            .padding(.top, -8)

            // 2. Logo — centered below back button, same as WalkSetUpHeader
            Image("isoWalkLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .padding(.top, -2)
        }
    }
}

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        WalkSessionHeader(onBack: {})
    }
}

