//
//  WalkSetUpView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//
//  PARENT VIEW — intentionally dumb.
//  Owns the ViewModel and all popup expanded states.
//  Modals rendered in root ZStack — guaranteed to float above everything.
//  Only one popup can be open at a time.
//  - FIXED: Implemented universal IsoWalkBackButton and standalone Image Area
//

import SwiftUI

struct WalkSetUpView: View {

    @State private var viewModel       = WalkSetUpViewModel()
    @Binding var selectedTab:            Int
    @State private var paceExpanded:     Bool = false
    @State private var durationExpanded: Bool = false
    @State private var musicExpanded:    Bool = false
    @State private var navigateToSession: Bool = false

    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            // 1. ZStack top alignment
            ZStack(alignment: .top) {
                
                // LAYER 1: Navigation (Floating)
                IsoWalkBackButton(theme: theme, onBack: { onDismiss() })
                    .zIndex(10)
                
                // LAYER 2: Main Content (Fixed)
                VStack(spacing: 0) {
                    
                    // Because this is the first item in a top-aligned VStack,
                    // it will perfectly match the ScrollView's starting position.
                    isoWalkThemeImageArea(theme: theme, isAnimated: true)

                    VStack(spacing: 12) {
                        PacePopUp(selectedPace: $viewModel.selectedPace, isExpanded: $paceExpanded)
                        DurationPopUp(selectedDuration: $viewModel.selectedDuration, isExpanded: $durationExpanded, selectedPace: viewModel.selectedPace)
                        MusicPopUp(viewModel: viewModel.musicViewModel, isExpanded: $musicExpanded)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    LetsGoButton(
                        isEnabled: viewModel.isReadyToStart,
                        action: {
                            viewModel.startWalkingSession()
                            navigateToSession = true
                        }
                    )
                    .padding(.bottom, 124)
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
                if paceExpanded { PacePopupModal(selectedPace: $viewModel.selectedPace, isExpanded: $paceExpanded).zIndex(100) }
                if durationExpanded { DurationPopupModal(selectedDuration: $viewModel.selectedDuration, isExpanded: $durationExpanded, selectedPace: viewModel.selectedPace).zIndex(100) }
                if musicExpanded { MusicPopupModal(viewModel: viewModel.musicViewModel, isExpanded: $musicExpanded, selectedPace: viewModel.selectedPace, selectedDuration: viewModel.selectedDuration).zIndex(100) }
            }
            .background {
                themeBackground
            }
            .onChange(of: paceExpanded)     { if paceExpanded     { durationExpanded = false; musicExpanded = false } }
            .onChange(of: durationExpanded) { if durationExpanded { paceExpanded     = false; musicExpanded = false } }
            .onChange(of: musicExpanded)    { if musicExpanded    { paceExpanded     = false; durationExpanded = false } }
            .navigationDestination(isPresented: $navigateToSession) {
                WalkSessionView(
                    selectedTab: $selectedTab,
                    duration: viewModel.selectedDuration,
                    pace: viewModel.selectedPace,
                    musicMode: viewModel.selectedMusicMode,
                    musicSelection: viewModel.musicViewModel.selection,
                    onDismissAll: { onDismiss() }
                )
            }
            .navigationBarHidden(true)
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

