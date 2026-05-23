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
    @State private var showingPaywall: Bool = false
    
    @State private var setupVM = WalkSetUpViewModel()
    @Environment(SessionManager.self) private var sessionManager
    
    // ✅ Read from the shared singleton to get real-time premium status
    private var storeVM: StoreViewModel { StoreViewModel.shared }

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
                    onStartWalking: {
                        // ✅ Disable animation for instant transition
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            showingSetup = true
                        }
                    },
                    onQuickStart: {
                        print("🚀 Quick Start triggered!")
                        // ✅ Disable animation for instant transition
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            showingQuickStart = true
                        }
                    }
                )
                .tag(0)
                
                ProgressScreenView(onShowBadges: {
                    // ✅ Disable animation for instant transition
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        showingBadges = true
                    }
                })
                .tag(1)
                
                FeaturesHomeScreenView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // MARK: - Nav Bar
            BottomNavBar(
                selectedTab: $selectedTab,
                onTabReTap: {
                    // ✅ Disable animation for instant transition
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        showingSetup = true
                    }
                }
            )
        }
        .ignoresSafeArea(.keyboard)
        
        // MARK: - Walk Setup Cover (Normal Start)
        .fullScreenCover(isPresented: $showingSetup) {
            WalkSetUpView(
                selectedTab: $selectedTab,
                onDismiss: {
                    // ✅ Disable animation when dismissing
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        showingSetup = false
                    }
                }
            )
            // ✅ Remove the slide-up animation
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
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
                    // ✅ Disable animation when dismissing
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        showingQuickStart = false
                    }
                }
            )
            // ✅ Remove the slide-up animation
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
        }
        
        // MARK: - Badges Cover
        .fullScreenCover(isPresented: $showingBadges) {
            BadgesScreenView(onDismiss: {
                // ✅ Disable animation when dismissing
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    showingBadges = false
                }
            })
            // ✅ Remove the slide-up animation
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
        }
        
        // MARK: - Paywall Cover
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView(isPresented: $showingPaywall)
            // ✅ Remove the slide-up animation
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
        }
        
        // ✅ Smart paywall logic - only shows once after status is confirmed
        .onChange(of: storeVM.hasCheckedStatus) { _, hasChecked in
            if hasChecked && !storeVM.isPremiumUser && !hasUserDismissedPaywall() {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    showingPaywall = true
                }
            }
        }
        
        // ✅ Track when user dismisses paywall (even without purchasing)
        .onChange(of: showingPaywall) { _, isShowing in
            if !isShowing {
                markPaywallAsDismissed()
            }
        }
    }
    
    // MARK: - Paywall Dismissal Tracking
    
    private func hasUserDismissedPaywall() -> Bool {
        UserDefaults.standard.bool(forKey: "hasSeenPaywall")
    }
    
    private func markPaywallAsDismissed() {
        UserDefaults.standard.set(true, forKey: "hasSeenPaywall")
    }
}

#Preview {
    isoWalkMainView()
        .environment(SessionManager())
}

