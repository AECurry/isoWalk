//
//  FeedbackSendButton.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//
//  CHILD COMPONENT — send button and privacy note only.
//  Parent passes the submit action in via closure.
//

import SwiftUI

struct FeedbackSendButton: View {

    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 12) {

            Button(action: onSubmit) {
                HStack(spacing: 10) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Send Feedback")
                        .font(.custom("Inter-SemiBold", size: 16))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isoWalkColors.balticBlue)
                        .shadow(color: isoWalkColors.balticBlue.opacity(0.3),
                                radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(.plain)

            Text("Sent through your email app directly to our support team. We never store your message on third-party servers.")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.45))
                .multilineTextAlignment(.center)
        }
    }
}

