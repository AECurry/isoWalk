//
//  TrackSequencePicker.swift
//  isoWalk
//
//  Created by AnnElaine on 3/12/26.
//
//
//  Simple radio-button picker for selecting a track from the library.
//  Used in TrackSequenceEditor when user taps a track row.
//

import SwiftUI

struct TrackSequencePicker: View {
    
    let pace: WalkPaceTag           // .normal or .brisk
    let currentTrackId: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var playingTrackId: String? = nil
    
    private var tracks: [SunoTrack] {
        pace == .normal
            ? SunoTrackLibrary.normalTracks
            : SunoTrackLibrary.briskTracks
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                isoWalkColors.parchment.ignoresSafeArea()
                
                List {
                    ForEach(tracks) { track in
                        Button(action: {
                            onSelect(track.id)
                            dismiss()
                        }) {
                            HStack(spacing: 12) {
                                // Play button
                                Button(action: {
                                    playPreview(track)
                                }) {
                                    Image(systemName: playingTrackId == track.id ? "stop.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(isoWalkColors.balticBlue)
                                }
                                .buttonStyle(.plain)
                                
                                // Track info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(track.title)
                                        .font(.system(
                                            size: 16,
                                            weight: track.id == currentTrackId ? .heavy : .regular
                                        ))
                                        .foregroundColor(
                                            track.id == currentTrackId
                                                ? isoWalkColors.forestGreen
                                                : isoWalkColors.jetBlack
                                        )
                                    
                                    Text(track.durationDisplay)
                                        .font(.custom("Inter-Regular", size: 14))
                                        .foregroundColor(isoWalkColors.slateGray)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())  // Makes entire row tappable
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.white)  // White row background
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)  // Hide default list background
                .contentMargins(.leading, 16)  // Add padding to prevent cutoff on left
            }
            .navigationTitle("Select \(pace.displayName) Track")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(isoWalkColors.parchment, for: .navigationBar)  // Theme color for nav bar
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)  // Force light mode
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        stopPlayback()
                        dismiss()
                    }
                    .foregroundColor(isoWalkColors.balticBlue)
                }
            }
            .onDisappear {
                stopPlayback()
            }
        }
    }
    
    // MARK: - Audio Preview
    
    private func playPreview(_ track: SunoTrack) {
        if playingTrackId == track.id {
            // Stop if already playing
            stopPlayback()
        } else {
            // Play 7-second preview using MusicPlayerService
            playingTrackId = track.id
            MusicPlayerService.shared.playPreview(trackId: track.id, duration: 7.0)
            
            // Auto-stop after 7 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                if playingTrackId == track.id {
                    stopPlayback()
                }
            }
        }
    }
    
    private func stopPlayback() {
        playingTrackId = nil
        MusicPlayerService.shared.stop()
    }
}

#Preview {
    TrackSequencePicker(
        pace: .normal,
        currentTrackId: "normal_01",
        onSelect: { _ in }
    )
}

