//
//  WalkSetUpView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI

// Explicitly track the active view flow state
enum SetupFlowState {
    case configuring
    case activeSession
}

struct WalkSetUpView: View {
    
    @State private var viewModel       = WalkSetUpViewModel()
    @Binding var selectedTab:            Int
    
    // Flow Layout State
    @State private var currentFlowState: SetupFlowState = .configuring
    
    // Popup states
    @State private var paceExpanded:     Bool = false
    @State private var durationExpanded: Bool = false
    @State private var musicExpanded:    Bool = false
    
    // Theme properties
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }
    
    let onDismiss: () -> Void
    let onCompleteSession: () -> Void
    
    var body: some View {
        ZStack {
            switch currentFlowState {
            case .configuring:
                // MARK: - Setup UI Interface Layer
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
                                PacePopUp(selectedPace: $viewModel.selectedPace, isExpanded: $paceExpanded)
                                DurationPopUp(selectedDuration: $viewModel.selectedDuration, isExpanded: $durationExpanded, selectedPace: viewModel.selectedPace)
                                MusicPopUp(viewModel: viewModel.musicViewModel, isExpanded: $musicExpanded)
                            }
                            .padding(.horizontal, 24)
                            
                            // Start Button
                            LetsGoButton(
                                isEnabled: viewModel.isReadyToStart,
                                action: {
                                    viewModel.startWalkingSession()
                                    
                                    // Hard cut forward to the session instantly
                                    var transaction = Transaction()
                                    transaction.disablesAnimations = true
                                    withTransaction(transaction) {
                                        currentFlowState = .activeSession
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
                    
                    // LAYER 4: POPUP MODALS
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
                .onAppear {
                    viewModel.loadLastPreferences()
                }
                .onChange(of: paceExpanded)     { if paceExpanded     { durationExpanded = false; musicExpanded = false } }
                .onChange(of: durationExpanded) { if durationExpanded { paceExpanded     = false; musicExpanded = false } }
                .onChange(of: musicExpanded)    { if musicExpanded    { paceExpanded     = false; durationExpanded = false } }
                
            case .activeSession:
                // MARK: - Active Walk Session Interface Layer
                WalkSessionView(
                    selectedTab: $selectedTab,
                    duration: viewModel.selectedDuration,
                    pace: viewModel.selectedPace,
                    musicMode: viewModel.selectedMusicMode,
                    musicSelection: viewModel.musicViewModel.selection,
                    onBackToSetup: {
                        // ✅ User tapped back button during session → Return to config screen
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            currentFlowState = .configuring
                        }
                    },
                    onCompleteSession: {
                        // ✅ Session finished successfully → Dismiss entire flow
                        onCompleteSession()
                    }
                )
            }
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
            transaction.animation = nil
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
        onDismiss: { print("Dismiss") },
        onCompleteSession: { print("Complete") }
    )
}

