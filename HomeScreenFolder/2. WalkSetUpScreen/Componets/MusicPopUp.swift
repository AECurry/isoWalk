//
//  MusicPopUp.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Trigger button + centered floating popup.
//  Receives selectedMusic and isExpanded bindings from WalkSetUpView.
//
//  PLACEHOLDER: Music selection coming soon. Button is disabled.
//  When ready: remove .allowsHitTesting(false) from the trigger button,
//  delete the placeholder body in MusicPopupModal, and add ForEach
//  over MusicOptions.allCases exactly like Pace and Duration.
//

import SwiftUI

struct MusicPopUp: View {
    @Binding var selectedMusic: MusicOptions
    @Binding var isExpanded: Bool

    @AppStorage("dropdownWidth") private var width: Double = 320
    @AppStorage("dropdownHeight") private var height: Double = 52
    @AppStorage("dropdownCornerRadius") private var cornerRadius: Double = 12
    @AppStorage("dropdownShadowRadius") private var shadowRadius: Double = 4

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Select Music")
                .font(.custom("Inter-SemiBold", size: 18))
                .foregroundColor(isoWalkColors.adaptiveText)
                .frame(width: width, alignment: .leading)

            // PLACEHOLDER: blocked until music is ready
            // When ready: remove .allowsHitTesting(false)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }) {
                HStack {
                    Image(systemName: "music.note")
                        .font(.system(size: 14))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                    Text("Music selection will be available soon")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                    Spacer()
                }
                .frame(width: width, height: height)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isoWalkColors.balticBlue.opacity(0.5))
                        .shadow(color: .black.opacity(0.15), radius: shadowRadius, x: 0, y: 2)
                )
            }
            .buttonStyle(.plain)
            .allowsHitTesting(false) // PLACEHOLDER: remove when music is ready
        }
    }
}

struct MusicPopupModal: View {
    @Binding var selectedMusic: MusicOptions
    @Binding var isExpanded: Bool
    @AppStorage("dropdownCornerRadius") private var cornerRadius: Double = 12
    @AppStorage("dropdownShadowRadius") private var shadowRadius: Double = 4

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
                }

            VStack(spacing: 0) {
                // FIX: Changed from Inter-SemiBold to Inter-Bold to match all other modals
                Text("Select Music")
                    .font(.custom("Inter-Bold", size: 18))
                    .foregroundColor(.white)
                    .padding(.vertical, 16)

                Divider().overlay(Color.white.opacity(0.2))

                // PLACEHOLDER: replace this block with ForEach over MusicOptions.allCases
                // when music is ready — follow the same pattern as PacePopupModal and DurationPopupModal
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Music selection coming soon")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(isoWalkColors.deepSpaceBlue)
                            .padding(24)
                    }
                }
                .frame(maxHeight: 320)
                // END PLACEHOLDER

                Divider().overlay(Color.white.opacity(0.2))

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
                }) {
                    Text("Cancel")
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isoWalkColors.balticBlue)
                    .shadow(color: .black.opacity(0.4), radius: 20, x: 8, y: 8)
            )
            .padding(.horizontal, 32)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }
}

#Preview {
    MusicPopUp(
        selectedMusic: .constant(.placeholder),
        isExpanded: .constant(false)
    )
    .padding()
    .background(isoWalkColors.parchment)
}
