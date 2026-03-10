//
//  SubmitFeedbackViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//
//  VIEWMODEL — all business logic for SubmitFeedbackScreenView.
//  Uses mailto: URL — no third-party servers, no privacy policy changes needed.
//  Opens whatever email app the user has installed (Gmail, Outlook, Apple Mail).
//  Pre-fills To, Subject hint, and message body with user's name and email.
//  Syncs any new email back to "userEmail" UserDefaults key.
//

import SwiftUI
import Observation

@Observable
final class SubmitFeedbackViewModel {

    // MARK: - Constants
    let companyEmail = "customersupport@beaconhilltechnologies.com"

    // MARK: - Form State
    var name: String  = ""
    var email: String = ""
    var message: String = ""

    // MARK: - UI State
    var showNoEmailAppAlert: Bool = false
    var showEmptyMessageAlert: Bool = false
    var emailError: String? = nil

    // MARK: - Keys
    private let nameKey  = "userName"
    private let emailKey = "userEmail"

    // MARK: - Init
    init() { loadUserInfo() }

    // MARK: - Load saved name and email
    private func loadUserInfo() {
        let savedName = UserDefaults.standard.string(forKey: nameKey) ?? ""
        name  = savedName.isEmpty ? "" : savedName == "Friend" ? "" : savedName
        email = UserDefaults.standard.string(forKey: emailKey) ?? ""
    }

    // MARK: - Validation
    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.contains("@") else { return false }
        let parts = trimmed.split(separator: "@")
        guard parts.count == 2, let domain = parts.last else { return false }
        return domain.contains(".")
    }

    // MARK: - Submit
    func submit() {
        // Validate message
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showEmptyMessageAlert = true
            return
        }

        // Validate email if provided
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedEmail.isEmpty && !isEmailValid {
            emailError = "Please enter a valid email address."
            return
        }

        // Sync email back to UserDefaults so Name & Email screen picks it up
        if !trimmedEmail.isEmpty && isEmailValid {
            UserDefaults.standard.set(trimmedEmail, forKey: emailKey)
        }

        // Build mailto URL
        let trimmedName    = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName    = trimmedName.isEmpty ? "isoWalk User" : trimmedName
        let subjectHint    = "Feedback from \(displayName)"
        let bodyIntro      = trimmedEmail.isEmpty
            ? "Name: \(displayName)\n\n"
            : "Name: \(displayName)\nEmail: \(trimmedEmail)\n\n"
        let fullBody       = bodyIntro + message

        var components = URLComponents()
        components.scheme = "mailto"
        components.path   = companyEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: subjectHint),
            URLQueryItem(name: "body",    value: fullBody)
        ]

        guard let url = components.url else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showNoEmailAppAlert = true
        }
    }

    // MARK: - Clear email error on edit
    func emailDidChange() {
        emailError = nil
    }
}
