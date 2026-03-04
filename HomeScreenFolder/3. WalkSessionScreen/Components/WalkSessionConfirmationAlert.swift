//
//  WalkSessionConfirmationAlert.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — reusable alert modifier.
//  Handles exit and stop confirmation dialogs for the walk session screen.
//

import SwiftUI

// MARK: - Alert Type Enum
enum SessionAlertType: Equatable {
    case backToSetup
    case exitToTab(Int)
    case stopSession

    var title: String {
        switch self {
        case .backToSetup:
            return "Leave Walking Session?"
        case .exitToTab:
            return "Leave Walking Session?"
        case .stopSession:
            return "Stop Walking Session?"
        }
    }

    var message: String {
        switch self {
        case .backToSetup:
            return "Are you sure you want to go back? Your session will be stopped."
        case .exitToTab:
            return "Are you sure you want to leave? Your session will be stopped."
        case .stopSession:
            return "Are you sure you want to stop this session? Your progress will not be saved."
        }
    }

    var confirmButtonText: String {
        switch self {
        case .backToSetup:
            return "Leave Session"
        case .exitToTab:
            return "Leave Session"
        case .stopSession:
            return "Stop Session"
        }
    }
}

// MARK: - View Modifier for Session Alerts
struct SessionConfirmationAlert: ViewModifier {
    @Binding var alertType: SessionAlertType?
    let onConfirm: (SessionAlertType) -> Void
    let onCancel: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                alertType?.title ?? "",
                isPresented: Binding(
                    get: { alertType != nil },
                    set: { if !$0 { alertType = nil } }
                )
            ) {
                Button("Cancel", role: .cancel) {
                    alertType = nil
                    onCancel()
                }
                Button(alertType?.confirmButtonText ?? "Confirm", role: .destructive) {
                    if let type = alertType {
                        onConfirm(type)
                    }
                    alertType = nil
                }
            } message: {
                Text(alertType?.message ?? "")
            }
    }
}

// MARK: - View Extension
extension View {
    func sessionConfirmationAlert(
        alertType: Binding<SessionAlertType?>,
        onConfirm: @escaping (SessionAlertType) -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.modifier(SessionConfirmationAlert(
            alertType: alertType,
            onConfirm: onConfirm,
            onCancel: onCancel
        ))
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var alertType: SessionAlertType? = nil

        var body: some View {
            VStack(spacing: 24) {
                Button("Show Back to Setup Alert") {
                    alertType = .backToSetup
                }
                Button("Show Exit to Tab Alert") {
                    alertType = .exitToTab(1)
                }
                Button("Show Stop Session Alert") {
                    alertType = .stopSession
                }
            }
            .padding()
            .sessionConfirmationAlert(
                alertType: $alertType,
                onConfirm: { type in print("Confirmed: \(type)") },
                onCancel: { print("Cancelled") }
            )
        }
    }
    return PreviewWrapper()
}
