//
//  isoWalkMainView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  ROOT VIEW — intentionally dumb.
//  Owns tab state, fullScreenCovers, and the single BottomNavBar instance.
//  Has zero knowledge of walk sessions, alerts, or what any tab contains.
//

import SwiftUI

struct isoWalkMainView: View {

    @State private var selectedTab: Int = 0
    @State private var showingSetup: Bool = false
    @State private var showingQuickStart: Bool = false
    @State private var showingBadges: Bool = false
    @State private var setupVM = WalkSetUpViewModel()
    @Environment(SessionManager.self) private var sessionManager

    var body: some View {
        ZStack(alignment: .bottom) {

            // MARK: - Tab Content
            TabView(selection: Binding(
                get: { selectedTab },
                set: { newTab in
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        selectedTab = newTab
                    }
                }
            )) {
                GetWalkingView(
                    selectedTab: $selectedTab,
                    onStartWalking: { showingSetup = true },
                    onQuickStart: {
                        print("🚀 Quick Start triggered!")
                        showingQuickStart = true
                    }
                )
                .tag(0)
                
                ProgressScreenView(onShowBadges: { showingBadges = true })
                    .tag(1)
                
                FeaturesHomeScreenView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // MARK: - Nav Bar
            BottomNavBar(
                selectedTab: $selectedTab,
                onTabReTap: { showingSetup = true }
            )
        }
        .ignoresSafeArea(.keyboard)
        
        // MARK: - Walk Setup Cover (Normal Start)
        .fullScreenCover(isPresented: $showingSetup) {
            WalkSetUpView(
                selectedTab: $selectedTab,
                onDismiss: { showingSetup = false }
            )
        }
        
        // MARK: - Quick Start Cover (Long Press)
        .fullScreenCover(isPresented: $showingQuickStart) {
            WalkSessionView(
                selectedTab: $selectedTab,
                duration: setupVM.selectedDuration,
                pace: setupVM.selectedPace,
                musicMode: setupVM.selectedMusicMode,
                musicSelection: setupVM.musicViewModel.selection,
                onDismissAll: {
                    showingQuickStart = false
                }
            )
        }
        
        // MARK: - Badges Cover
        .fullScreenCover(isPresented: $showingBadges) {
            BadgesScreenView(onDismiss: { showingBadges = false })
        }
    }
}

#Preview {
    isoWalkMainView()
        .environment(SessionManager())
}
