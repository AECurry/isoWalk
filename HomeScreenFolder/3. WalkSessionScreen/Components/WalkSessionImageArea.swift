//
//  WalkSessionImageArea.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Displays the selected theme image statically during a walk session.
//  Static (no animation) — two animations already exist on this screen.
//

import SwiftUI

struct WalkSessionImageArea: View {
    let theme: IsoWalkTheme

    var body: some View {
        Image(theme.mainImageName)
            .resizable()
            .scaledToFit()
            .frame(width: AnimatedImageSize.medium.dimension,
                   height: AnimatedImageSize.medium.dimension)
            .padding(.vertical, 8)
    }
}

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        WalkSessionImageArea(theme: IsoWalkThemes.all[0])
    }
}

