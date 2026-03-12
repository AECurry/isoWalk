//
//  MusicOptions.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  Core music model for the entire app.
//  Three modes: no music, isoWalk SUNO tracks (timer-driven),
//  My Music via Apple Music or Spotify (song-driven).
//
//  Cross-screen: used by WalkSetUpScreen (pick) and
//  WalkSessionView (play).
//

import Foundation

// ─────────────────────────────────────────
// MARK: - Music Mode
// ─────────────────────────────────────────

enum MusicMode: String, Codable, CaseIterable, Identifiable {
    case noMusic
    case isoWalkTracks
    case myMusic

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

// ─────────────────────────────────────────
// MARK: - Streaming Service
// ─────────────────────────────────────────

enum MusicService: String, Codable, CaseIterable, Identifiable {
    case appleMusic
    case spotify

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
        case .spotify:    return "music.mic"
        }
    }
}

// ─────────────────────────────────────────
// MARK: - Walk Pace Tag
// ─────────────────────────────────────────

enum WalkPaceTag: String, Codable, CaseIterable, Identifiable {
    case normal
    case brisk

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .brisk:  return "Brisk"
        }
    }
}

// ─────────────────────────────────────────
// MARK: - SUNO Track
// ─────────────────────────────────────────

struct SunoTrack: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let pace: WalkPaceTag
    let durationSeconds: Int        // exact — no cutoff, timed to interval

    var durationDisplay: String {
        let m = durationSeconds / 60
        let s = durationSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// ─────────────────────────────────────────
// MARK: - Streaming Song
// ─────────────────────────────────────────

struct TaggedSong: Identifiable, Codable, Hashable {
    let id: String              // persistent ID from MusicKit or Spotify
    let title: String
    let artist: String
    let durationSeconds: Int
    var paceTag: WalkPaceTag

    var durationDisplay: String {
        let m = durationSeconds / 60
        let s = durationSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// ─────────────────────────────────────────
// MARK: - Full Music Selection (persisted)
// ─────────────────────────────────────────

struct MusicSelection: Codable {
    var mode: MusicMode        = .noMusic
    var selectedNormalTrackId: String? = nil
    var selectedBriskTrackId:  String? = nil
    var musicService: MusicService     = .appleMusic
    var taggedSongs: [TaggedSong]      = []

    // Ordered playback: N→B→N→B→...→N (always ends on Normal)
    var playbackSequence: [TaggedSong] {
        let normals = taggedSongs.filter { $0.paceTag == .normal }
        let brisks  = taggedSongs.filter { $0.paceTag == .brisk  }
        var result: [TaggedSong] = []
        let cycles = min(normals.count, brisks.count + 1)
        for i in 0..<cycles {
            result.append(normals[i])
            if i < brisks.count { result.append(brisks[i]) }
        }
        return result
    }

    // Total session time in seconds (My Music mode only)
    var totalSessionSeconds: Int {
        guard mode == .myMusic else { return 0 }
        return playbackSequence.reduce(0) { $0 + $1.durationSeconds }
    }

    var totalSessionDisplay: String {
        let total = totalSessionSeconds
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d hr %d min %d sec", h, m, s)
        } else {
            return String(format: "%d min %d sec", m, s)
        }
    }

    // Minimum: 15 min = 5 cycles = 3 Normal + 2 Brisk, ends on Normal
    var isValidForMyMusic: Bool {
        guard mode == .myMusic else { return true }
        let normals = taggedSongs.filter { $0.paceTag == .normal }.count
        let brisks  = taggedSongs.filter { $0.paceTag == .brisk  }.count
        guard normals >= 3, brisks >= 2       else { return false }
        guard normals == brisks + 1           else { return false }
        return totalSessionSeconds >= 15 * 60
    }

    var validationMessage: String? {
        guard mode == .myMusic else { return nil }
        let normals = taggedSongs.filter { $0.paceTag == .normal }.count
        let brisks  = taggedSongs.filter { $0.paceTag == .brisk  }.count
        if normals < 3 || brisks < 2 {
            return "Add at least 3 Normal and 2 Brisk songs (5 cycles minimum)."
        }
        if normals != brisks + 1 {
            return "You need one more Normal song than Brisk so the session ends on a cool-down."
        }
        if totalSessionSeconds < 15 * 60 {
            return "Session must be at least 15 minutes."
        }
        return nil
    }

    // ── Persistence ──────────────────────────────────────────────────
    private static let key = "musicSelection"

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    static func load() -> MusicSelection {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let saved = try? JSONDecoder().decode(MusicSelection.self, from: data)
        else { return MusicSelection() }
        return saved
    }
}

