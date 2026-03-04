//
//  ProgressScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/27/26.
//
//  PARENT VIEW — intentionally dumb.
//  Assembles all Progress screen components.
//

import SwiftUI

struct ProgressScreenView: View {
    var body: some View {
        ZStack {
            // Background
            Image("GoldenTextureBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Header with greeting, badge display, and total walks
                    ProgressHeader()

                    // TODO: Add more components here as we build them:
                    // - Total miles display
                    // - Today's activity section
                    // - Streak cards
                    // - Badges earned section

                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ProgressScreenView()
}
