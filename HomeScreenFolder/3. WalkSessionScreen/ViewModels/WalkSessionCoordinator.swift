//
//  WalkSessionCoordinator.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COORDINATOR — owns ALL navigation and alert decision logic for WalkSessionView.
//  WalkSessionView is dumb — it only reads showAlert/alertType and calls
//  the three handle methods. Zero business logic lives in the view.
//

import SwiftUI
import Observation

@Observable
final class WalkSessionCoordinator {

    // Alert state — observed directly by WalkSessionView's .alert modifier
    var showAlert = false
    var alertType: SessionAlertType? = nil

    // Outcome callbacks — wired by WalkSessionView in .onAppear
    var onBackToSetup: (() -> Void)?
    var onStopSession: (() -> Void)?
    var onNavigateToTab: ((Int) -> Void)?
    var onPauseForAlert: (() -> Void)?
    var onResumeAfterAlert: (() -> Void)?

    // MARK: - Triggers (called by view buttons and nav bar)

    func handleBackButtonTap() {
        onPauseForAlert?()
        alertType = .backToSetup
        showAlert = true
    }

    func handleStopButtonTap() {
        onPauseForAlert?()
        alertType = .stopSession
        showAlert = true
    }

    func handleTabTap(_ tab: Int) {
        onPauseForAlert?()
        alertType = .exitToTab(tab)
        showAlert = true
    }

    // MARK: - User Decisions (called by view alert buttons)

    func confirmAlert() {
        guard let type = alertType else { return }
        alertType = nil
        showAlert = false
        switch type {
        case .backToSetup:
            onBackToSetup?()
        case .stopSession:
            onStopSession?()
        case .exitToTab(let tab):
            onNavigateToTab?(tab)
        }
    }

    func cancelAlert() {
        alertType = nil
        showAlert = false
        onResumeAfterAlert?()
    }
}
