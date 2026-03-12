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
                }
            }
            .listStyle(.plain)
            .contentMargins(.leading, 16)  // Add padding to prevent cutoff on left
            .navigationTitle("Select \(pace.displayName) Track")
            .navigationBarTitleDisplayMode(.inline)
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
            // Play 6-8 second preview
            playingTrackId = track.id
            
            // TODO: Implement actual audio playback via MusicPlayerService
            // For now, just simulate with a timer
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                if playingTrackId == track.id {
                    stopPlayback()
                }
            }
            
            print("Playing preview: \(track.title) for 7 seconds")
        }
    }
    
    private func stopPlayback() {
        playingTrackId = nil
        // TODO: Stop actual audio playback
        print("Stopped preview playback")
    }
}

#Preview {
    TrackSequencePicker(
        pace: .normal,
        currentTrackId: "normal_01",
        onSelect: { _ in }
    )
}

