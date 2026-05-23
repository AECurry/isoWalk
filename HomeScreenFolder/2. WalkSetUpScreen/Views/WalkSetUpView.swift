//
//  WalkSetUpView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  PARENT VIEW — Source of Truth.
//  Owns the ViewModel and all popup expanded states.
//  Modals rendered in root ZStack — guaranteed to float above everything.
//

import SwiftUI

struct WalkSetUpView: View {
    
    // ✅ ViewModel handles the default values (.brisk and .thirty)
    @State private var viewModel       = WalkSetUpViewModel()
    @Binding var selectedTab:            Int
    
    // Popup states
    @State private var paceExpanded:     Bool = false
    @State private var durationExpanded: Bool = false
    @State private var musicExpanded:    Bool = false
    @State private var navigateToSession: Bool = false
    
    // Theme properties
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }
    
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                
                // LAYER 1: Navigation (Floating Back Button)
                IsoWalkBackButton(theme: theme, onBack: { onDismiss() })
                    .zIndex(10)
                
                // LAYER 2: Main Content (Scrollable)
                VStack(spacing: -24) {
                    
                    // MARK: - Theme Image Area
                    isoWalkThemeImageArea(theme: theme, isAnimated: true)
                        .frame(maxWidth: .infinity)
                        .zIndex(1)
                    
                    // MARK: - Scrollable Setup Options
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            // Pace selection
                            PacePopUp(selectedPace: $viewModel.selectedPace, isExpanded: $paceExpanded)
                            
                            // Duration selection
                            DurationPopUp(selectedDuration: $viewModel.selectedDuration, isExpanded: $durationExpanded, selectedPace: viewModel.selectedPace)
                            
                            // Music selection
                            MusicPopUp(viewModel: viewModel.musicViewModel, isExpanded: $musicExpanded)
                        }
                        .padding(.horizontal, 24)
                        
                        // Start Button
                        LetsGoButton(
                            isEnabled: viewModel.isReadyToStart,
                            action: {
                                // Save selections to UserDefaults before starting
                                viewModel.startWalkingSession()
                                
                                // ✅ Disable navigation animation for instant transition
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) {
                                    navigateToSession = true
                                }
                            }
                        )
                        .padding(.top, 0)
                        .padding(.bottom, 150)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .zIndex(0)
                }
                
                // LAYER 3: Bottom Nav Bar
                if !navigateToSession {
                    VStack {
                        Spacer()
                        BottomNavBar(
                            selectedTab: $selectedTab,
                            onTabReTap: { onDismiss() },
                            onTabChange: { tab in
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) { selectedTab = tab }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { onDismiss() }
                            }
                        )
                    }
                    .zIndex(5)
                }
                
                // LAYER 4: POPUP MODALS
                // These are placed last in the ZStack to ensure they cover the screen
                if paceExpanded {
                    PacePopupModal(selectedPace: $viewModel.selectedPace, isExpanded: $paceExpanded)
                        .zIndex(100)
                }
                
                if durationExpanded {
                    DurationPopupModal(selectedDuration: $viewModel.selectedDuration, isExpanded: $durationExpanded, selectedPace: viewModel.selectedPace)
                        .zIndex(100)
                }
                
                if musicExpanded {
                    MusicPopupModal(viewModel: viewModel.musicViewModel, isExpanded: $musicExpanded, selectedPace: viewModel.selectedPace, selectedDuration: viewModel.selectedDuration)
                        .zIndex(100)
                }
            }
            .background {
                themeBackground
            }
            // ✅ CRITICAL: Re-load preferences when view appears to ensure UI is in sync
            .onAppear {
                viewModel.loadLastPreferences()
            }
            // Ensure only one popup is open at a time
            .onChange(of: paceExpanded)     { if paceExpanded     { durationExpanded = false; musicExpanded = false } }
            .onChange(of: durationExpanded) { if durationExpanded { paceExpanded     = false; musicExpanded = false } }
            .onChange(of: musicExpanded)    { if musicExpanded    { paceExpanded     = false; durationExpanded = false } }
            
            // Navigation to the actual walk
            .navigationDestination(isPresented: $navigateToSession) {
                WalkSessionView(
                    selectedTab: $selectedTab,
                    duration: viewModel.selectedDuration,
                    pace: viewModel.selectedPace,
                    musicMode: viewModel.selectedMusicMode,
                    musicSelection: viewModel.musicViewModel.selection,
                    onDismissAll: { onDismiss() }
                )
                .toolbar(.hidden, for: .navigationBar)
                // ✅ Remove the slide animation for NavigationStack push
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        // ✅ Also disable NavigationStack's default animations
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
    
    @ViewBuilder
    private var themeBackground: some View {
        if let bgName = theme.backgroundImageName {
            Image(bgName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        } else {
            theme.backgroundColor.ignoresSafeArea()
        }
    }
}

#Preview {
    WalkSetUpView(
        selectedTab: .constant(0),
        onDismiss: { print("Dismiss") }
    )
}

