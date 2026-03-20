//
//  WalkSessionView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns the ViewModel and Coordinator. Passes bindings down to children.
//  Zero business logic — all decisions live in Coordinator and ViewModel.
//

import SwiftUI

struct WalkSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    @State private var viewModel = WalkSessionViewModel()
    @State private var coordinator = WalkSessionCoordinator()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    let duration: DurationOptions
    let pace: PaceOptions
    let musicMode: MusicMode
    let musicSelection: MusicSelection
    var onDismissAll: (() -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {
            // LAYER 1: Background
            themeBackground

            // LAYER 2: Main Content
            VStack(spacing: 0) {
                // FIXED: Added the 16pt padding to match WalkSetUpView exactly
                WalkSessionHeader(theme: theme, onBack: {
                    coordinator.handleBackButtonTap()
                })
                .padding(.top, 16)

                // FIXED: Added the -12pt padding to match the ImageArea placement
                WalkSessionImageArea(theme: theme)
                    .padding(.top, -12)
                
                VStack(spacing: 24) {
                    TimerDisplay(
                        timeString: viewModel.formattedTime,
                        isActive: viewModel.timerState == .running
                    )

                    AudioVisualizer(
                        amplitudes: viewModel.amplitudes,
                        isActive: viewModel.isAudioPlaying
                    )

                    PlaybackControls(
                        timerState: viewModel.timerState,
                        onPlayPause: { viewModel.playPause() },
                        onStop: { coordinator.handleStopButtonTap() }
                    )
                }
                .padding(.top, 8)

                Spacer()
            }
            // Removed the "hack" padding from before;
            // the 16pt on the header is the proper fix.
            .padding(.bottom, 100)

            // LAYER 3: Bottom Nav Bar
            BottomNavBar(
                selectedTab: $selectedTab,
                onTabReTap: {
                    coordinator.handleTabTap(selectedTab)
                },
                onTabChange: { tab in
                    coordinator.handleTabTap(tab)
                }
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            let c = coordinator
            let vm = viewModel
            let dismissAll = onDismissAll

            c.onPauseForAlert    = { vm.pauseForAlert() }
            c.onResumeAfterAlert = { vm.resumeAfterAlert() }
            c.onBackToSetup      = { vm.stopSession(); dismiss() }
            c.onStopSession      = { vm.stopSession() }
            c.onNavigateToTab    = { tab in
                vm.stopSession()
                selectedTab = tab
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dismissAll?()
                }
            }

            vm.initializeSession(
                duration: duration,
                pace: pace,
                musicMode: musicMode,
                musicSelection: musicSelection
            )
        }
        .onDisappear {
            viewModel.saveSessionState()
        }
        .onChange(of: scenePhase) { _, newPhase in
            viewModel.handleScenePhase(newPhase)
        }
        .alert(
            coordinator.alertType?.title ?? "",
            isPresented: $coordinator.showAlert
        ) {
            Button("Cancel", role: .cancel) { coordinator.cancelAlert() }
            Button(coordinator.alertType?.confirmButtonText ?? "Confirm",
                   role: .destructive) { coordinator.confirmAlert() }
        } message: {
            Text(coordinator.alertType?.message ?? "")
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
