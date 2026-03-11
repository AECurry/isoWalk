//
//  MusicPopUp.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//  LOCATION: WalkSetUpScreen/Components/
//
//  Matches the Pace and Duration pattern exactly:
//  — MusicPopUp        : collapsed trigger card shown on WalkSetUpView
//  — MusicPopupModal   : full picker sheet rendered in WalkSetUpView's ZStack
//
//  All music logic lives in MusicViewModel (MusicFolder).
//  Tab content is in IsoWalkTracksTab.swift and MyMusicTab.swift.
//
//  FIX: UIScreen.main replaced with GeometryReader — deprecated in iOS 16,
//  removed in iOS 26.
//

import SwiftUI

// ─────────────────────────────────────────
// MARK: - MusicPopUp (collapsed card)
// ─────────────────────────────────────────

struct MusicPopUp: View {

    @Bindable var viewModel: MusicViewModel
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Select Music")
                .font(.custom("Inter-SemiBold", size: 18))
                .foregroundColor(isoWalkColors.adaptiveText)
                .frame(width: 320, alignment: .leading)

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }) {
                HStack {
                    Image(systemName: viewModel.selectedMode.iconName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                    Text(viewModel.summaryLabel)
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(width: 320, height: 52)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isoWalkColors.balticBlue)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// ─────────────────────────────────────────
// MARK: - MusicPopupModal (full picker sheet)
// ─────────────────────────────────────────

struct MusicPopupModal: View {

    @Bindable var viewModel: MusicViewModel
    @Binding var isExpanded: Bool

    var body: some View {
        // GeometryReader replaces UIScreen.main — works on iOS 16 through 26+
        GeometryReader { screen in
            ZStack(alignment: .bottom) {

                // Dimmed backdrop — tap to dismiss
                Color.black.opacity(0.40)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
                    }

                VStack(spacing: 0) {

                    // Handle
                    Capsule()
                        .fill(Color.white.opacity(0.50))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 16)

                    // Header
                    HStack {
                        Text("Select Music")
                            .font(.custom("Inter-Bold", size: 18))
                            .foregroundColor(.white)
                        Spacer()
                        Button("Done") {
                            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
                        }
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.white.opacity(0.70))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                    // Mode tabs
                    HStack(spacing: 0) {
                        ForEach(MusicMode.allCases) { mode in
                            modeTab(mode)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                    Divider().overlay(Color.white.opacity(0.20))

                    // Tab content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            switch viewModel.activeTab {
                            case .noMusic:
                                noMusicContent
                            case .isoWalkTracks:
                                IsoWalkTracksTab(viewModel: viewModel)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 20)
                            case .myMusic:
                                MyMusicTab(viewModel: viewModel)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 20)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(isoWalkColors.balticBlue)
                        .ignoresSafeArea(edges: .bottom)
                )
                // 82% of actual screen height via GeometryReader
                .frame(maxHeight: screen.size.height * 0.82)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            .frame(width: screen.size.width, height: screen.size.height)
        }
        .ignoresSafeArea()
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
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
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
                .padding(.top, 32)

            Text("No Music Selected")
                .font(.custom("Inter-Bold", size: 18))
                .foregroundColor(.white)

            Text("The interval timer will still guide your pace with chimes and voice cues.")
                .font(.custom("Inter-Regular", size: 15))
                .foregroundColor(.white.opacity(0.60))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
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
