//
//  GetWalkingView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI

struct GetWalkingView: View {
    @Environment(SessionManager.self) private var sessionManager
    @AppStorage(IsoWalkThemes.selectedThemeKey) private var selectedThemeId: String = IsoWalkThemes.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkThemes.current(selectedId: selectedThemeId) }

   
    let onStartWalking: () -> Void

    var body: some View {
        ZStack {
            // Background Layer
            Group {
                if let bgName = theme.backgroundImageName {
                    Image(bgName).resizable().aspectRatio(contentMode: .fill)
                } else {
                    theme.backgroundColor
                }
            }
            .ignoresSafeArea()

            VStack {
                IsoWalkLogoView().padding(.top, 16)
                Spacer().frame(height: 16)
                ImageAreaView(theme: theme)
                Spacer()

                StartWalkingButton {
                    onStartWalking()
                }
                .padding(.bottom, 124)
            }
        }
    }
}

#Preview {
    GetWalkingView(onStartWalking: {})
        .environment(SessionManager())
}
