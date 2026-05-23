//
//  DurationPopUp.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
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
    @AppStorage("dropdownHeight") private var height: Double = 64
    @AppStorage("dropdownCornerRadius") private var cornerRadius: Double = 12
    @AppStorage("dropdownShadowRadius") private var shadowRadius: Double = 4

    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    
    private var theme: IsoWalkTheme {
        IsoWalkTheme.current(selectedId: selectedThemeId)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("2. Select Duration")
                .font(.custom("Inter-SemiBold", size: 18))
                .foregroundColor(theme.primaryTextColor)
                .frame(width: width, alignment: .leading)

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }) {
                HStack {
                    // ✅ Fixed: Always shows the binding value
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
                    .font(.custom("Inter-Bold", size: 32))
                    .foregroundColor(.white)
                    .padding(.vertical, 16)

                Divider().overlay(Color.white.opacity(0.2))
                
                // Pace indicator
                Text("For \(selectedPace.ratioDisplay) pace")
                    .font(.custom("Inter-Medium", size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.vertical, 12)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(DurationOptions.allCases) { option in
                            Button(action: {
                                // ✅ Update selection
                                selectedDuration = option
                                // ✅ Sync with ViewModel's key immediately
                                UserDefaults.standard.set(option.rawValue, forKey: "lastDuration")
                                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
                            }) {
                                let info = option.cycleInfo(for: selectedPace)
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("\(option.displayName) - \(info.totalCycles) cycles")
                                            .font(.custom("Inter-Bold", size: 22))
                                            .foregroundColor(selectedDuration == option
                                                ? isoWalkColors.deepSpaceBlue
                                                : .white)
                                        
                                        Spacer()
                                        
                                        if selectedDuration == option {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .font(.system(size: 18, weight: .bold))
                                        }
                                    }
                                    
                                    Text("(\(info.normalCount - 1) Normal • \(info.briskCount) Brisk • 1 Cooldown)")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.85)
                                }
                                .padding(.horizontal, 16)
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

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
                }) {
                    Text("Cancel")
                        .font(.custom("Inter-Medium", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isoWalkColors.deepSpaceBlue)
                }
                .buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
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

