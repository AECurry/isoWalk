//
//  MyMusicTab.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  Tab content for "My Music" mode (Apple Music / Spotify integration).
//

import SwiftUI
import MusicKit

struct MyMusicTab: View {
    
    @Bindable var viewModel: MusicViewModel
    @State private var appleMusicService = AppleMusicService.shared
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Service selector
            servicePicker
            
            // Empty state / Coming soon
            if viewModel.selection.taggedSongs.isEmpty {
                emptyState
            } else {
                songList
            }
            
            Spacer()
        }
        .padding(.top, 24)
    }
    
    // MARK: - Service Picker
    
    private var servicePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Music Source")
                .font(.custom("Inter-SemiBold", size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            HStack(spacing: 12) {
                ForEach(MusicService.allCases) { service in
                    Button(action: {
                        viewModel.setService(service)
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: service.iconName)
                                .font(.system(size: 24))
                            Text(service.displayName)
                                .font(.custom("Inter-Medium", size: 14))
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(
                            viewModel.selection.musicService == service
                                ? isoWalkColors.balticBlue
                                : .white.opacity(0.6)
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)  // Fixed height for equal boxes
                        .background(
                            viewModel.selection.musicService == service
                                ? Color.white
                                : Color.white.opacity(0.1)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.25))
                .padding(.top, 32)
            
            Text("No songs added yet")
                .font(.custom("Inter-Bold", size: 18))
                .foregroundColor(.white)
            
            Text("Add songs from \(viewModel.selection.musicService.displayName) to create your custom interval playlist.")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.white.opacity(0.60))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Authorization & Add Songs Button
            Button(action: {
                handleAddSongsTapped()
            }) {
                HStack {
                    Image(systemName: buttonIcon)
                        .font(.system(size: 16))
                    Text(buttonText)
                        .font(.custom("Inter-SemiBold", size: 16))
                }
                .foregroundColor(isoWalkColors.balticBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            // Validation message
            if let message = viewModel.validationMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                    Text(message)
                        .font(.custom("Inter-Regular", size: 12))
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Methods for Button Logic
    
    private var isAppleMusicSelected: Bool {
        // Assuming MusicService enum has an .appleMusic case
        viewModel.selection.musicService.displayName.contains("Apple")
    }
    
    private var buttonText: String {
        if isAppleMusicSelected && !appleMusicService.isAuthorized {
            return "Connect Apple Music"
        }
        return "Add Songs from \(viewModel.selection.musicService.displayName)"
    }
    
    private var buttonIcon: String {
        if isAppleMusicSelected && !appleMusicService.isAuthorized {
            return "link"
        }
        return "plus.circle.fill"
    }
    
    private func handleAddSongsTapped() {
        if isAppleMusicSelected {
            if !appleMusicService.isAuthorized {
                // Request Auth
                Task {
                    await appleMusicService.requestAuthorization()
                }
            } else {
                // TODO: Present Music Search Sheet
                print("Presenting Apple Music Search...")
            }
        } else {
            // TODO: Handle Spotify logic
            print("Spotify integration coming soon...")
        }
    }
    
    // MARK: - Song List
    
    private var songList: some View {
        VStack(spacing: 12) {
            Text("Your Playlist (\(viewModel.selection.taggedSongs.count) songs)")
                .font(.custom("Inter-SemiBold", size: 14))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(viewModel.selection.taggedSongs) { song in
                        songRow(song)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func songRow(_ song: TaggedSong) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white)
                
                Text(song.artist)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Pace tag
            Text(song.paceTag.displayName)
                .font(.custom("Inter-Medium", size: 12))
                .foregroundColor(song.paceTag == .normal ? .green : .orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.15))
                .cornerRadius(6)
            
            // Duration
            Text(song.durationDisplay)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ZStack {
        // Assuming isoWalkColors.balticBlue exists in your global scope
        Color.blue.ignoresSafeArea() // Placeholder for preview
        
        MyMusicTab(viewModel: MusicViewModel())
    }
}

