//
//  MyMusicTab.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//  UPDATED 3/26/26: Temporarily showing "Coming Soon" placeholder
//  Full implementation preserved below (commented out)
//
//  Tab content for "My Music" mode (Apple Music / Spotify integration).
//

import SwiftUI
import MusicKit

struct MyMusicTab: View {
    
    @Bindable var viewModel: MusicViewModel
    @State private var appleMusicService = AppleMusicService.shared
    
    var body: some View {
        // MARK: - COMING SOON PLACEHOLDER
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "music.note.list")
                .font(.system(size: 72))
                .foregroundColor(.white.opacity(0.25))
            
            Text("Coming Soon")
                .font(.custom("Inter-Bold", size: 28))
                .foregroundColor(.white)
            
            Text("We're building the ability to sync your Apple Music and Spotify playlists for interval training.")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
                .lineSpacing(4)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /* MARK: - FULL IMPLEMENTATION (Preserved for later)
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Service picker
            servicePicker
            
            // Voice picker
            voicePicker
            
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
                        .frame(height: 80)
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
    
    // MARK: - Voice Picker
        
    private var voicePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Interval Voice Cues")
                .font(.custom("Inter-SemiBold", size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            // 👉 Replaced standard segmented picker with your custom toggle component
            CustomVoiceToggle()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.25))
                .padding(.top, 16)
            
            Text("No songs added yet")
                .font(.custom("Inter-Bold", size: 18))
                .foregroundColor(.white)
            
            Text("Add songs from \(viewModel.selection.musicService.displayName) to create your custom interval playlist.")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.white.opacity(0.60))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
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
    
    // MARK: - Helper Methods
    
    private var isAppleMusicSelected: Bool {
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
                Task {
                    await appleMusicService.requestAuthorization()
                }
            } else {
                print("Presenting Apple Music Search...")
            }
        } else {
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
            
            Text(song.paceTag.displayName)
                .font(.custom("Inter-Medium", size: 12))
                .foregroundColor(song.paceTag == .normal ? .green : .orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.15))
                .cornerRadius(6)
            
            Text(song.durationDisplay)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
    
    */ // End of commented implementation
}

#Preview {
    ZStack {
        isoWalkColors.balticBlue.ignoresSafeArea()
        MyMusicTab(viewModel: MusicViewModel())
    }
}

//```

//## 🎯 **What This Does**

//1. ✅ **Shows "Coming Soon" when user taps "My Music"**
//2. ✅ **Preserves ALL your existing code** (commented out)
//3. ✅ **Professional look** - users won't think it's broken
//4. ✅ **Easy to restore** - just uncomment the block when ready

//## 📱 **What Users Will See**

//When they tap "My Music":
//```
//         🎵 (large music icon)
       
//       Coming Soon
       
//  We're building the ability to sync
//   your Apple Music and Spotify
//   playlists for interval training.

