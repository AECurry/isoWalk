//
//  MyMusicTab.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  Tab content for "My Music" mode (Apple Music / Spotify integration).
//
//  TODO: Implement in next sprint:
//  - MusicKit integration for Apple Music
//  - Spotify SDK integration
//  - Song tagging (Normal vs Brisk)
//  - Playlist building with N-B-N-B validation
//

import SwiftUI

struct MyMusicTab: View {
    
    @Bindable var viewModel: MusicViewModel
    
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
            
            // TODO: Add Songs button
            Button(action: {
                // TODO: Open MusicKit picker or Spotify auth
                print("Add songs from \(viewModel.selection.musicService.displayName)")
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("Add Songs from \(viewModel.selection.musicService.displayName)")
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
        isoWalkColors.balticBlue.ignoresSafeArea()
        
        MyMusicTab(viewModel: MusicViewModel())
    }
}
