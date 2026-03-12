//
//  MusicPopUp.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  Matches the Pace and Duration pattern exactly:
//  — MusicPopUp        : collapsed trigger card shown on WalkSetUpView
//  — MusicPopupModal   : centered modal matching Pace/Duration style
//
//  All music logic lives in MusicViewModel (MusicFolder).
//  Tab content is in IsoWalkTracksTab.swift and MyMusicTab.swift.
//

import SwiftUI

// ─────────────────────────────────────────
// MARK: - MusicPopUp (collapsed card)
// ─────────────────────────────────────────

struct MusicPopUp: View {

    @Bindable var viewModel: MusicViewModel
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

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }) {
                HStack {
                    Image(systemName: viewModel.selectedMode.iconName)
                        .font(.system(size: 15, weight: .medium))
                    Text(viewModel.summaryLabel)
                        .font(.custom("Inter-Medium", size: 16))
                        .lineLimit(1)
                    Spacer()
                }
                .foregroundColor(.white)
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

// ─────────────────────────────────────────
// MARK: - MusicPopupModal (centered modal - matches Pace/Duration)
// ─────────────────────────────────────────

struct MusicPopupModal: View {

    @Bindable var viewModel: MusicViewModel
    @Binding var isExpanded: Bool

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
                Text("Select Music")
                    .font(.custom("Inter-Bold", size: 18))
                    .foregroundColor(.white)
                    .padding(.vertical, 16)

                Divider().overlay(Color.white.opacity(0.2))

                // Mode tabs
                HStack(spacing: 0) {
                    ForEach(MusicMode.allCases) { mode in
                        modeTab(mode)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)

                Divider().overlay(Color.white.opacity(0.20))

                // Tab content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        switch viewModel.activeTab {
                        case .noMusic:
                            noMusicContent
                        case .isoWalkTracks:
                            IsoWalkTracksTab(viewModel: viewModel)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                        case .myMusic:
                            MyMusicTab(viewModel: viewModel)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .frame(maxHeight: 400)

                Divider().overlay(Color.white.opacity(0.2))

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
                }) {
                    Text("Done")
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
        .onAppear {
            viewModel.activeTab = viewModel.selectedMode
        }
    }

    // MARK: - Mode Tab Button
    private func modeTab(_ mode: MusicMode) -> some View {
        let isActive = viewModel.activeTab == mode
        return Button(action: {
            viewModel.activeTab = mode
            viewModel.setMode(mode)
        }) {
            VStack(spacing: 4) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 16, weight: .medium))
                Text(mode.displayName)
                    .font(.custom("Inter-SemiBold", size: 11))
            }
            .foregroundColor(isActive ? .white : .white.opacity(0.40))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? Color.white.opacity(0.20) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - No Music Content
    private var noMusicContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "speaker.slash.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.25))
                .padding(.top, 24)

            Text("No Music Selected")
                .font(.custom("Inter-Bold", size: 18))
                .foregroundColor(.white)

            Text("The interval timer will still guide your pace with chimes and voice cues.")
                .font(.custom("Inter-Regular", size: 15))
                .foregroundColor(.white.opacity(0.60))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        MusicPopUp(
            viewModel: MusicViewModel(),
            isExpanded: .constant(false)
        )
        .padding()
    }
}
