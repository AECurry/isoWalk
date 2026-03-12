//
//  MyMusicTab.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  CHILD COMPONENT — My Music tab inside MusicPopupModal.
//  Service picker (Apple Music / Spotify).
//  Song list with pace tag toggle and remove.
//  Validation feedback when minimum not met.
//
//  NOTE: "Add Songs" button is stubbed — MusicKit and Spotify SDK
//  wiring happens in MusicPlayerService next sprint.
//

import SwiftUI

struct MyMusicTab: View {

    @Bindable var viewModel: MusicViewModel
    @State private var showSpotifyWarning: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // MARK: - Service Picker
            VStack(alignment: .leading, spacing: 10) {
                Text("Music Source")
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(.white.opacity(0.55))

                HStack(spacing: 12) {
                    ForEach(MusicService.allCases) { service in
                        serviceButton(service)
                    }
                }
            }

            Divider().overlay(Color.white.opacity(0.20))

            // MARK: - Song List or Empty State
            if viewModel.selection.taggedSongs.isEmpty {
                emptyState
            } else {
                songList
            }

            // MARK: - Add Songs Button
            Button(action: addSongsTapped) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("Add Songs from \(viewModel.selection.musicService.displayName)")
                        .font(.custom("Inter-SemiBold", size: 14))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.50), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)

            // MARK: - Session Time
            if !viewModel.selection.taggedSongs.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.50))
                    Text("Session: \(viewModel.selection.totalSessionDisplay)")
                        .font(.custom("Inter-Regular", size: 13))
                        .foregroundColor(.white.opacity(0.70))
                    Spacer()
                }
            }

            // MARK: - Validation
            if let message = viewModel.validationMessage {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    Text(message)
                        .font(.custom("Inter-Regular", size: 13))
                        .foregroundColor(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text("Music plays song by song. The app signals each pace change with a chime and voice cue when a song ends.")
                .font(.custom("Inter-Regular", size: 13))
                .foregroundColor(.white.opacity(0.50))
                .multilineTextAlignment(.leading)
        }
        .alert("Spotify Premium Required", isPresented: $showSpotifyWarning) {
            Button("Continue with Spotify") { viewModel.setService(.spotify) }
            Button("Use Apple Music Instead", role: .cancel) { viewModel.setService(.appleMusic) }
        } message: {
            Text("Controlling Spotify playback requires a Spotify Premium account. Free accounts are not supported.")
        }
    }

    // MARK: - Service Button
    private func serviceButton(_ service: MusicService) -> some View {
        let isSelected = viewModel.selection.musicService == service
        return Button(action: {
            if service == .spotify { showSpotifyWarning = true }
            else { viewModel.setService(service) }
        }) {
            HStack(spacing: 6) {
                Image(systemName: service.iconName)
                    .font(.system(size: 14))
                Text(service.displayName)
                    .font(.custom("Inter-SemiBold", size: 13))
            }
            .foregroundColor(isSelected ? isoWalkColors.balticBlue : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "music.note.list")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.25))
            Text("No songs added yet")
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.white.opacity(0.45))
            Text("Add at least 3 Normal and 2 Brisk songs")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.35))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Song List
    private var songList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.selection.taggedSongs) { song in
                songRow(song)
                if song.id != viewModel.selection.taggedSongs.last?.id {
                    Divider()
                        .overlay(Color.white.opacity(0.15))
                        .padding(.leading, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.10))
        )
    }

    private func songRow(_ song: TaggedSong) -> some View {
        HStack(spacing: 12) {

            // Tap pace badge to toggle Normal ↔ Brisk
            Button(action: { viewModel.togglePaceTag(id: song.id) }) {
                Text(song.paceTag.displayName)
                    .font(.custom("Inter-SemiBold", size: 11))
                    .foregroundColor(isoWalkColors.balticBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white)
                    )
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text("\(song.artist) · \(song.durationDisplay)")
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.55))
                    .lineLimit(1)
            }

            Spacer()

            Button(action: { viewModel.removeSong(id: song.id) }) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.50))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    // MARK: - Add Songs (stubbed — MusicKit / Spotify wired next sprint)
    private func addSongsTapped() {
        // TODO: present MPMediaPickerController for Apple Music
        // TODO: present Spotify search sheet for Spotify
        let placeholder = TaggedSong(
            id: UUID().uuidString,
            title: "Sample Song",
            artist: "Sample Artist",
            durationSeconds: 210,
            paceTag: .normal
        )
        viewModel.addSong(placeholder)
    }
}

