//
//  WalkSetUpImageArea.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//
//  COMPONENT — dumb child.
//  Displays the theme image in the setup screen.
//  Receives theme from parent. Owns nothing.
//  - FIXED: Replaced deprecated UIScreen.main.bounds with GeometryReader
//  - FIXED: Added exhaustive switch coverage for .video and .none support
//

import SwiftUI

struct WalkSetUpImageArea: View {
    let theme: IsoWalkTheme

    var body: some View {
        SquareThemeEngineView(
            theme: theme,
            frameWidth: AnimatedImageSize.medium.dimension
        )
        
        .padding(.bottom, 16)
    }
}

