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
import SwiftData

struct WalkSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTab: Int
    
    @State private var viewModel = WalkSessionViewModel()
    @State private var coordinator = WalkSessionCoordinator()
    @State private var hapticManager = HapticPaceManager()
    
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    
    // Tracks the state of the Developer Toggle
    @AppStorage("isDeveloperTestMode") private var isTestModeActive: Bool = false
    
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }
    
    let duration: DurationOptions
    let pace: PaceOptions
    let musicMode: MusicMode
    let musicSelection: MusicSelection
    var onDismissAll: (() -> Void)?
    
    private var currentBPM: Int {
        if viewModel.isBriskInterval {
            return 140
        } else {
            return 100
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // LAYER 1: Floating Navigation
            IsoWalkBackButton(theme: theme, onBack: {
                coordinator.handleBackButtonTap()
            })
            .zIndex(10)
            
            // LAYER 2: Main Content
            VStack(spacing: 0) {
                
                isoWalkThemeImageArea(theme: theme, isAnimated: false)
                    .contentShape(Rectangle())
                    .allowsHitTesting(true)
                    .zIndex(1)
                    .onTapGesture(count: 2) {
                        print("🫵 Double-tap detected! Triggering \(currentBPM) BPM haptics.")
                        hapticManager.playPace(bpm: currentBPM)
                    }
                
                VStack(spacing: 24) {
                    TimerDisplay(
                        timeString: viewModel.formattedTime,
                        isActive: viewModel.timerState == .running
                    )
                    
                    AudioVisualizer(
                        amplitudes: viewModel.amplitudes,
                        isActive: viewModel.isAudioPlaying,
                        bpm: currentBPM
                    )
                    
                    PlaybackControls(
                        timerState: viewModel.timerState,
                        onPlayPause: { viewModel.playPause() },
                        onStop: { coordinator.handleStopButtonTap() }
                    )
                    
                    // NEW: The Developer Toggle View injected here
                    DeveloperTestToggleView(isOn: $isTestModeActive)
                        .padding(.top, 20)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.bottom, 40)
            
            // LAYER 3: Completion Popup Overlay
            if viewModel.showCompletionPopup {
                CompletionPopupView {
                    coordinator.handleCompletionProgressTap()
                }
                .zIndex(100)
                .transition(.opacity.combined(with: .scale))
            }
            
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showCompletionPopup)
        .background {
            themeBackground
        }
        .navigationBarHidden(true)
        .onAppear {
            let c = coordinator
            let vm = viewModel
            let dismissAll = onDismissAll
            
            vm.modelContext = modelContext
            
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
                musicSelection: musicSelection,
                isTesting: isTestModeActive // Passes current toggle state
            )
        }
        // INSTANTLY adjusts session if the teacher flips the toggle mid-screen
        .onChange(of: isTestModeActive) { _, newValue in
            viewModel.stopSession()
            viewModel.initializeSession(
                duration: duration,
                pace: pace,
                musicMode: musicMode,
                musicSelection: musicSelection,
                isTesting: newValue
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

