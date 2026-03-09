//
//  EmailInputField.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//  
//  COMPONENT — dumb child.
//  Email text field with label, validation error message, and Save button.
//  Receives all state and callbacks from parent — owns nothing.
//

import SwiftUI

struct EmailInputField: View {

    @Binding var email: String
    let errorMessage: String?
    let isSaved: Bool
    let onSave: () -> Void

    private let fieldCornerRadius: CGFloat = 12
    private let labelFontSize: CGFloat = 16
    private let inputFontSize: CGFloat = 17

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Label
            Text("Email")
                .font(.custom("Inter-SemiBold", size: labelFontSize))
                .foregroundColor(isoWalkColors.deepSpaceBlue)

            // Text field
            TextField("", text: $email)
                .font(.custom("Inter-Regular", size: inputFontSize))
                .foregroundColor(isoWalkColors.deepSpaceBlue)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: fieldCornerRadius)
                        .fill(isoWalkColors.deepSpaceBlue.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: fieldCornerRadius)
                        .strokeBorder(
                            errorMessage != nil
                            ? Color.red.opacity(0.6)
                            : Color.clear,
                            lineWidth: 1.5
                        )
                )
                .submitLabel(.done)
                .onSubmit { onSave() }

            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundColor(.red.opacity(0.8))
                    .transition(.opacity)
            }

            // Save button
            Button(action: onSave) {
                Text(isSaved ? "Saved ✓" : "Save Email")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: fieldCornerRadius)
                            .fill(isSaved
                                  ? isoWalkColors.forestGreen
                                  : isoWalkColors.balticBlue)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
            .animation(.easeInOut(duration: 0.2), value: isSaved)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        EmailInputField(
            email: .constant(""),
            errorMessage: nil,
            isSaved: false,
            onSave: {}
        )
        EmailInputField(
            email: .constant("bad-email"),
            errorMessage: "Please enter a valid email address.",
            isSaved: false,
            onSave: {}
        )
        EmailInputField(
            email: .constant("friend@email.com"),
            errorMessage: nil,
            isSaved: true,
            onSave: {}
        )
    }
    .padding()
    .background(isoWalkColors.parchment)
}
