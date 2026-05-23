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
    @State private var showQuickStartTooltip = false
    
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

                ZStack(alignment: .top) {
                    StartWalkingButton(
                        action: {
                            onStartWalking()
                        },
                        longPressAction: {
                            print("👉 Long press detected - Quick Start!")
                            let hasCompletedFirst = UserDefaults.standard.bool(forKey: "hasCompletedFirstWalk")
                            
                            if hasCompletedFirst {
                                let impact = UIImpactFeedbackGenerator(style: .heavy)
                                impact.impactOccurred()
                                onQuickStart()
                            } else {
                                print("⚠️ First walk not completed - Quick Start disabled")
                            }
                        }
                    )
                    
                    // Quick Start Tooltip (appears above button)
                    if showQuickStartTooltip {
                        FeatureTooltip(
                            message: "💡 Press and hold the 'Start Walking' button to quickly start your last walk",
                            position: .bottom,
                            onDismiss: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showQuickStartTooltip = false
                                }
                                FeatureTooltipManager.markAsSeen("quickStart")
                            }
                        )
                        .offset(y: -80)
                        .zIndex(10)
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(.bottom, 124)
            }
        }
        .onAppear {
            checkAndShowTooltips()
        }
    }
    
    // MARK: - Tooltip Logic
    
    private func checkAndShowTooltips() {
        let hasCompletedFirst = UserDefaults.standard.bool(forKey: "hasCompletedFirstWalk")
        
        // Only show Quick Start tooltip if feature is unlocked AND it's the right launch count
        if hasCompletedFirst && FeatureTooltipManager.shouldShow("quickStart") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showQuickStartTooltip = true
                }
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

