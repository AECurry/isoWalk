//
//  isoWalkMainView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  ROOT VIEW — intentionally dumb.
//  Owns tab state, fullScreenCovers, and the single BottomNavBar instance.
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
    
    // Read from the shared singleton to get real-time premium status
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
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            showingSetup = true
                        }
                    },
                    onQuickStart: {
                        print("🚀 Quick Start triggered!")
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            showingQuickStart = true
                        }
                    }
                )
                .tag(0)
                
                ProgressScreenView(onShowBadges: {
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
                    // ✅ Backed out from setup state: dismiss smoothly back to home screen
                    showingSetup = false
                },
                onCompleteSession: {
                    // ✅ Session finished completely: hard drop back to home screen
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        showingSetup = false
                    }
                }
            )
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
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        showingQuickStart = false
                    }
                }
            )
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
        }
        
        // MARK: - Badges Cover
        .fullScreenCover(isPresented: $showingBadges) {
            BadgesScreenView(onDismiss: {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    showingBadges = false
                }
            })
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
        }
        
        // MARK: - Paywall Cover
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView(isPresented: $showingPaywall)
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
        }
        
        // Smart paywall logic - only shows once after status is confirmed
        .onChange(of: storeVM.hasCheckedStatus) { _, hasChecked in
            if hasChecked && !storeVM.isPremiumUser && !hasUserDismissedPaywall() {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    showingPaywall = true
                }
            }
        }
        
        // Track when user dismisses paywall (even without purchasing)
        .onChange(of: showingPaywall) { _, isShowing in
            if !isShowing {
                markPaywallAsDismissed()
            }
        }
    }
    
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

