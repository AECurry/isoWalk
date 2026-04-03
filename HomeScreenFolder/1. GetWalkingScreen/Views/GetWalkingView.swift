//
//  GetWalkingView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI

struct GetWalkingView: View {
    @Environment(SessionManager.self) private var sessionManager
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }
    
    @State private var setupVM = WalkSetUpViewModel()
    
    @Binding var selectedTab: Int
    
    let onStartWalking: () -> Void
    let onQuickStart: () -> Void

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

                StartWalkingButton(
                    action: {
                        onStartWalking() // Normal tap → opens setup
                    },
                    longPressAction: {
                        print("👉 Long press detected - Quick Start!")
                        let hasCompletedFirst = UserDefaults.standard.bool(forKey: "hasCompletedFirstWalk")
                        
                        if hasCompletedFirst {
                            // Haptic feedback
                            let impact = UIImpactFeedbackGenerator(style: .heavy)
                            impact.impactOccurred()
                            
                            onQuickStart() // ← Call parent to handle presentation
                        } else {
                            print("⚠️ First walk not completed - Quick Start disabled")
                        }
                    }
                )
                .padding(.bottom, 124)
            }
        }
    }
}

#Preview {
    GetWalkingView(
        selectedTab: .constant(0),
        onStartWalking: {},
        onQuickStart: {}
    )
    .environment(SessionManager())
}

