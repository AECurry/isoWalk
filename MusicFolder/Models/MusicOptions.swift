//
//  MusicOptions.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//  Updated 3/12/26: Added filename property to support duration-specific audio files
//
//  Models for music selection in WalkSetUpView.
//  - MusicMode        : no music | isoWalk tracks | my music
//  - MusicService     : Apple Music vs Spotify
//  - WalkPaceTag      : normal vs brisk
//  - SunoTrack        : ONE track from the isoWalk library
//  - TaggedSong       : ONE song from user's Apple/Spotify library
//  - MusicSelection   : the complete music package for a walk session
//

import SwiftUI

// ==========================================
// MARK: - MUSIC MODE
// ==========================================

enum MusicMode: String, CaseIterable, Identifiable {
    case noMusic       = "noMusic"
    case isoWalkTracks = "isoWalkTracks"
    case myMusic       = "myMusic"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .noMusic:       return "No Music"
        case .isoWalkTracks: return "isoWalk Tracks"
        case .myMusic:       return "My Music"
        }
    }

    var iconName: String {
        switch self {
        case .noMusic:       return "speaker.slash.fill"
        case .isoWalkTracks: return "music.note.list"
        case .myMusic:       return "music.note"
        }
    }
}

// ==========================================
// MARK: - MUSIC SERVICE
// ==========================================

enum MusicService: String, CaseIterable, Identifiable {
    case appleMusic = "appleMusic"
    case spotify    = "spotify"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .appleMusic: return "Apple Music"
        case .spotify:    return "Spotify"
        }
    }

    var iconName: String {
        switch self {
        case .appleMusic: return "applelogo"
        case .spotify:    return "s.circle.fill"
        }
    }
}

// ==========================================
// MARK: - WALK PACE TAG
// ==========================================

enum WalkPaceTag: String, Codable {
    case normal = "normal"
    case brisk  = "brisk"

    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .brisk:  return "Brisk"
        }
    }
}

// ==========================================
// MARK: - SUNO TRACK (isoWalk bundled music)
// ==========================================

struct SunoTrack: Identifiable, Codable {
    let id: String
    let title: String           // User-facing name: "Quiet Morning Alone"
    let baseFilename: String    // Base filename without duration: "Quiet Morning Alone (Jane Austen_Normal_112"
    let pace: WalkPaceTag
    let bpm: Int?               // Optional: 112
    let style: String?          // Optional: "Jane Austen"
    
    // Computed property: builds full filename based on duration needed
    func filename(forDuration minutes: Int) -> String {
        return "\(baseFilename)_\(minutes)min)"
    }
    
    // Display duration in MM:SS format
    var durationDisplay: String {
        return "3:00"  // Base duration, actual duration determined at playback
    }
}

// ==========================================
// MARK: - TAGGED SONG (user's Apple/Spotify music)
// ==========================================

struct TaggedSong: Identifiable, Codable {
    let id: String
    let title: String
    let artist: String
    let duration: Int           // in seconds
    let paceTag: WalkPaceTag
    let serviceId: String       // Apple Music ID or Spotify URI

    var durationDisplay: String {
        let mins = duration / 60
        let secs = duration % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// ==========================================
// MARK: - MUSIC SELECTION (the complete package)
// ==========================================

struct MusicSelection: Codable {
    var musicMode: MusicMode
    var musicService: MusicService
    var sunoTracks: [SunoTrack]
    var taggedSongs: [TaggedSong]

    init(
        musicMode: MusicMode = .noMusic,
        musicService: MusicService = .appleMusic,
        sunoTracks: [SunoTrack] = [],
        taggedSongs: [TaggedSong] = []
    ) {
        self.musicMode = musicMode
        self.musicService = musicService
        self.sunoTracks = sunoTracks
        self.taggedSongs = taggedSongs
    }

    // Validation helpers
    var hasValidSunoPlaylist: Bool {
        !sunoTracks.isEmpty
    }

    var hasValidTaggedPlaylist: Bool {
        let normalCount = taggedSongs.filter { $0.paceTag == .normal }.count
        let briskCount = taggedSongs.filter { $0.paceTag == .brisk }.count
        return normalCount > 0 && briskCount > 0
    }
}
