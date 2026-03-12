//
//  IsoWalkTracksTab.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  CHILD COMPONENT — isoWalk Tracks tab inside MusicPopupModal.
//  Normal pack picker + Brisk pack picker.
//  UI only — selection logic in MusicViewModel.
//

import SwiftUI

struct IsoWalkTracksTab: View {

    @Bindable var viewModel: MusicViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            trackSection(
                title: "Normal Pace",
                subtitle: "Calm, steady — about 100 BPM",
                accentColor: isoWalkColors.balticBlue,
                tracks: viewModel.normalTracks,
                selectedId: viewModel.selection.selectedNormalTrackId,
                onSelect: { viewModel.selectNormalTrack($0) }
            )

            Divider()

            trackSection(
                title: "Brisk Pace",
                subtitle: "Upbeat, energizing — about 140 BPM",
                accentColor: Color("rustRed"),
                tracks: viewModel.briskTracks,
                selectedId: viewModel.selection.selectedBriskTrackId,
                onSelect: { viewModel.selectBriskTrack($0) }
            )

            Text("isoWalk tracks are timed precisely to your interval. The app switches tracks automatically with a chime and voice cue.")
                .font(.custom("Inter-Regular", size: 13))
                .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.50))
                .multilineTextAlignment(.leading)
                .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isoWalkColors.ivory)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
    }

    // MARK: - Track Section
    private func trackSection(
        title: String,
        subtitle: String,
        accentColor: Color,
        tracks: [SunoTrack],
        selectedId: String?,
        onSelect: @escaping (SunoTrack) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Inter-Bold", size: 15))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)
                Text(subtitle)
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.55))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(tracks) { track in
                        trackChip(
                            track: track,
                            isSelected: selectedId == track.id,
                            accentColor: accentColor,
                            onSelect: { onSelect(track) }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Track Chip
    private func trackChip(
        track: SunoTrack,
        isSelected: Bool,
        accentColor: Color,
        onSelect: @escaping () -> Void
    ) -> some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.custom("Inter-SemiBold", size: 13))
                    .foregroundColor(isSelected ? .white : isoWalkColors.deepSpaceBlue)
                Text(track.durationDisplay)
                    .font(.custom("Inter-Regular", size: 11))
                    .foregroundColor(isSelected
                                     ? .white.opacity(0.80)
                                     : isoWalkColors.deepSpaceBlue.opacity(0.55))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? accentColor : accentColor.opacity(0.10))
            )
        }
        .buttonStyle(.plain)
    }
}

