//
//  IsoWalkLogoView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI

struct IsoWalkLogoView: View {
    // Pulls in the current theme
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    var body: some View {
        // Automatically swaps between "isoWalkLogo1" or whatever the theme specifies!
        Image(theme.logoImageName)
            .resizable()
            .scaledToFit()
            .frame(height: 56)
            .padding(.vertical, 16)
    }
}
