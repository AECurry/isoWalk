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
    @AppStorage(IsoWalkThemes.selectedThemeKey) private var selectedThemeId: String = IsoWalkThemes.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkThemes.current(selectedId: selectedThemeId) }

    let duration: DurationOptions
    let pace: PaceOptions
    let musicMode: MusicMode              // was: music: MusicOptions
    let musicSelection: MusicSelection    // full selection for playback
    var onDismissAll: (() -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {
            themeBackground

            VStack(spacing: 0) {
                WalkSessionHeader(onBack: {
                    coordinator.handleBackButtonTap()
                })

                WalkSessionImageArea(theme: theme)

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

                Spacer()
            }
            .padding(.bottom, 100)

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

#Preview {
    @Previewable @State var selectedTab = 0
    WalkSessionView(
        selectedTab: $selectedTab,
        duration: .twenty,
        pace: .steady,
        musicMode: .noMusic,
        musicSelection: MusicSelection()
    )
}
