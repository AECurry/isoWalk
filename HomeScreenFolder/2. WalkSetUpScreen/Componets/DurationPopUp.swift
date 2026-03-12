//
//  DurationPopUp.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  Updated 3/12/26: Match PacePopUp structure exactly
//
//  COMPONENT — dumb child.
//  Trigger button + modal popup.
//  Receives selectedDuration, isExpanded, and selectedPace bindings from WalkSetUpView.
//

import SwiftUI

struct DurationPopUp: View {
    @Binding var selectedDuration: DurationOptions
    @Binding var isExpanded: Bool
    var selectedPace: PaceOptions

    @AppStorage("dropdownWidth") private var width: Double = 320
    @AppStorage("dropdownHeight") private var height: Double = 52
    @AppStorage("dropdownCornerRadius") private var cornerRadius: Double = 12
    @AppStorage("dropdownShadowRadius") private var shadowRadius: Double = 4

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Select Duration")
                .font(.custom("Inter-SemiBold", size: 18))
                .foregroundColor(isoWalkColors.adaptiveText)
                .frame(width: width, alignment: .leading)

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }) {
                HStack {
                    Text(selectedDuration.displayName)
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(width: width, height: height)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isoWalkColors.balticBlue)
                        .shadow(color: .black.opacity(0.25), radius: shadowRadius, x: 0, y: 2)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

struct DurationPopupModal: View {
    @Binding var selectedDuration: DurationOptions
    @Binding var isExpanded: Bool
    var selectedPace: PaceOptions
    
    @AppStorage("dropdownCornerRadius") private var cornerRadius: Double = 12
    @AppStorage("dropdownShadowRadius") private var shadowRadius: Double = 4

    var body: some View {
        ZStack {
            // Dimmed backdrop — tap to dismiss
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
                }

            // Centered modal card
            VStack(spacing: 0) {
                Text("Select Duration")
                    .font(.custom("Inter-Bold", size: 18))
                    .foregroundColor(.white)
                    .padding(.vertical, 16)

                Divider().overlay(Color.white.opacity(0.2))
                
                // Pace indicator
                Text("For \(selectedPace.ratioDisplay) pace")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 12)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(DurationOptions.allCases) { option in
                            Button(action: {
                                selectedDuration = option
                                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
                            }) {
                                let info = option.cycleInfo(for: selectedPace)
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(option.displayName)
                                            .font(.custom("Inter-Bold", size: 24))
                                            .foregroundColor(selectedDuration == option
                                                ? isoWalkColors.deepSpaceBlue
                                                : .white)
                                        Spacer()
                                        if selectedDuration == option {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    Text("\(info.totalCycles) cycles (\(info.normalCount) Normal · \(info.briskCount) Brisk)")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    if info.cooldownExtension > 0 {
                                        Text("Final cooldown: \(info.finalNormalDuration) min (+\(info.cooldownExtension) min)")
                                            .font(.custom("Inter-Regular", size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(selectedDuration == option
                                    ? Color.white.opacity(0.15)
                                    : Color.clear)
                            }
                            .buttonStyle(.plain)

                            if option.id != DurationOptions.allCases.last?.id {
                                Divider().overlay(Color.white.opacity(0.2))
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)

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
                    .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 8)
            )
            .padding(.horizontal, 32)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }
}

#Preview {
    DurationPopUp(
        selectedDuration: .constant(.thirty),
        isExpanded: .constant(false),
        selectedPace: .steady
    )
    .padding()
    .background(isoWalkColors.parchment)
}

