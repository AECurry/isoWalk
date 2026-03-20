//
//  ThemeHeaderPreview.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  Updated 3/19/26: Added the seamless conveyor belt looping animation
//

import SwiftUI

struct ThemeHeaderPreview: View {
    let theme: IsoWalkTheme
    let frameSize: CGFloat

    var body: some View {
        SquareThemeEngineView(theme: theme, frameWidth: frameSize)
    }
}
