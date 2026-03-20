//
//  ImageAreaView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//

import SwiftUI

struct ImageAreaView: View {
    let theme: IsoWalkTheme

    var body: some View {
        SquareThemeEngineView(
            theme: theme,
            frameWidth: AnimatedImageSize.extraLarge.dimension
        )
    }
}
