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
    
    // NEW: Tooltip states
    @State private var showQuickStartTooltip = false
    @State private var showHapticTooltip = false
    
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }
    
    let duration: DurationOptions
    let pace: PaceOptions
    let musicMode: MusicMode
    let musicSelection: MusicSelection
    
    // ✅ NEW: Separate callbacks for different exit scenarios
    var onBackToSetup: (() -> Void)? = nil        // Back button → Return to config
    var onCompleteSession: (() -> Void)? = nil    // Session complete → Dismiss flow
    var onDismissAll: (() -> Void)? = nil         // Quick Start flow → Dismiss everything
    
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
            
            // LAYER 2: Main Content (NEVER MOVES)
            VStack(spacing: 0) {
                
                isoWalkThemeImageArea(theme: theme, isAnimated: false)
                    .contentShape(Rectangle())
                    .allowsHitTesting(true)
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
                }
                .padding(.top, 16)
                
                Spacer()
            }
            .padding(.bottom, 40)
            
            // LAYER 3: Floating Tooltip (Independent, doesn't affect layout)
            if showHapticTooltip {
                VStack {
                    Spacer()
                        .frame(height: 200)
                    
                    FeatureTooltip(
                        message: "💡 Double-tap the image to feel the walking pace as haptic vibrations",
                        position: .bottom,
                        onDismiss: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showHapticTooltip = false
                            }
                            FeatureTooltipManager.markAsSeen("hapticPace")
                        }
                    )
                    .frame(maxWidth: 340)
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                }
                .zIndex(56)
            }
            
            // LAYER 4: Completion Popup Overlay
            if viewModel.showCompletionPopup {
                CompletionPopupView {
                    coordinator.handleCompletionProgressTap()
                }
                .zIndex(56)
                .transition(.opacity.combined(with: .scale))
            }
            
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showCompletionPopup)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showHapticTooltip)
        .background {
            themeBackground
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            let c = coordinator
            let vm = viewModel
            
            vm.modelContext = modelContext
            
            c.onPauseForAlert    = { vm.pauseForAlert() }
            c.onResumeAfterAlert = { vm.resumeAfterAlert() }
            
            // ✅ CRITICAL: Different behavior based on context
            c.onBackToSetup = {
                vm.stopSession()
                
                if let onBackToSetup = onBackToSetup {
                    // Embedded in WalkSetUpView → Go back to config screen
                    onBackToSetup()
                } else if let onDismissAll = onDismissAll {
                    // Quick Start flow → Dismiss everything
                    onDismissAll()
                } else {
                    // Fallback → Use system dismiss
                    dismiss()
                }
            }
            
            c.onStopSession = { vm.stopSession() }
            
            c.onNavigateToTab = { tab in
                vm.stopSession()
                selectedTab = tab
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let onCompleteSession = onCompleteSession {
                        onCompleteSession()
                    } else if let onDismissAll = onDismissAll {
                        onDismissAll()
                    }
                }
            }
            
            vm.initializeSession(
                duration: duration,
                pace: pace,
                musicMode: musicMode,
                musicSelection: musicSelection,
                isTesting: false
            )
            
            checkAndShowTooltips()
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
        .onShake {
            #if DEBUG
            UserDefaults.standard.removeObject(forKey: "hasSeenTooltip_hapticPace")
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showHapticTooltip = true
            }
            print("🎬 Tooltips reset via shake gesture")
            #endif
        }
    }
    
    // MARK: - Tooltip Logic
    
    private func checkAndShowTooltips() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if FeatureTooltipManager.shouldShow("hapticPace") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showHapticTooltip = true
                }
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

// MARK: - Shake Gesture Extension

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeGestureModifier(action: action))
    }
}

struct ShakeGestureModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

