//
//  WalkSetUpView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  LOCATION: WalkSetUpScreen/Views/
//
//  PARENT VIEW — intentionally dumb.
//  Owns the ViewModel and all popup expanded states.
//  Modals rendered in root ZStack — guaranteed to float above everything.
//  Only one popup can be open at a time.
//

import SwiftUI

struct WalkSetUpView: View {

    @State private var viewModel       = WalkSetUpViewModel()
    @Binding var selectedTab:            Int
    @State private var paceExpanded:     Bool = false
    @State private var durationExpanded: Bool = false
    @State private var musicExpanded:    Bool = false
    @State private var navigateToSession: Bool = false

    @AppStorage(IsoWalkThemes.selectedThemeKey) private var selectedThemeId: String = IsoWalkThemes.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkThemes.current(selectedId: selectedThemeId) }

    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                themeBackground

                // 1. MAIN CONTENT
                VStack(spacing: 0) {
                    WalkSetUpHeader(theme: theme, onBack: { onDismiss() })
                        .padding(.top, 16)

                    VStack(spacing: 12) {
                        PacePopUp(
                            selectedPace: $viewModel.selectedPace,
                            isExpanded: $paceExpanded
                        )
                        DurationPopUp(
                            selectedDuration: $viewModel.selectedDuration,
                            isExpanded: $durationExpanded
                        )
                        MusicPopUp(
                            viewModel: viewModel.musicViewModel,
                            isExpanded: $musicExpanded
                        )
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

                // 2. POPUP MODALS — float above everything in ZStack
                if paceExpanded {
                    PacePopupModal(
                        selectedPace: $viewModel.selectedPace,
                        isExpanded: $paceExpanded
                    )
                    .ignoresSafeArea()
                    .zIndex(10)
                }
                if durationExpanded {
                    DurationPopupModal(
                        selectedDuration: $viewModel.selectedDuration,
                        isExpanded: $durationExpanded
                    )
                    .ignoresSafeArea()
                    .zIndex(10)
                }
                if musicExpanded {
                    MusicPopupModal(
                        viewModel: viewModel.musicViewModel,
                        isExpanded: $musicExpanded
                    )
                    .ignoresSafeArea()
                    .zIndex(10)
                }
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
        .overlay(alignment: .bottom) {
            if !navigateToSession {
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
