//
//  NameEmailViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//
//  VIEWMODEL — all business logic for NameEmailScreenView.
//  The View is dumb — it only reads from and calls into this ViewModel.
//  Persists to UserDefaults — consistent with rest of app.
//

import SwiftUI
import Observation

@Observable
final class NameEmailViewModel {

    // MARK: - Constants
    let maxNameLength = 9

    // MARK: - State
    var name: String = "" {
        didSet {
            // Hard stop at 9 characters
            if name.count > maxNameLength {
                name = String(name.prefix(maxNameLength))
            }
            // Auto-save name as user types
            saveName()
        }
    }

    var email: String = "" {
        didSet {
            // Reset validation when user edits
            emailError = nil
        }
    }

    var emailError: String? = nil
    var emailSaved: Bool = false

    // MARK: - Keys
    private let nameKey  = "userName"
    private let emailKey = "userEmail"

    // MARK: - Init
    init() {
        let savedName = UserDefaults.standard.string(forKey: nameKey) ?? ""
        name = savedName.isEmpty ? "Friend" : savedName
        email = UserDefaults.standard.string(forKey: emailKey) ?? ""
    }

    // MARK: - Validation

    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        // Must contain @ and at least one . after the @
        guard trimmed.contains("@") else { return false }
        let parts = trimmed.split(separator: "@")
        guard parts.count == 2, let domain = parts.last else { return false }
        return domain.contains(".")
    }

    // MARK: - Intent

    // Auto-called when name changes
    private func saveName() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let valueToSave = trimmed.isEmpty ? "Friend" : trimmed
        UserDefaults.standard.set(valueToSave, forKey: nameKey)
    }

    // Called when user submits email (taps Save or return key)
    func saveEmail() {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            // Allow clearing email
            UserDefaults.standard.set("", forKey: emailKey)
            emailError = nil
            emailSaved = true
            return
        }
        guard isEmailValid else {
            emailError = "Please enter a valid email address."
            emailSaved = false
            return
        }
        UserDefaults.standard.set(trimmed, forKey: emailKey)
        emailError = nil
        emailSaved = true
    }

    // Called when name field loses focus — ensure "Friend" fallback
    func nameFieldDidEndEditing() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            name = "Friend"
        }
    }
}
