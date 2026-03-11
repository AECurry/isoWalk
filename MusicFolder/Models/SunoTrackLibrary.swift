//
//  SunoTrackLibrary.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  All 20 isoWalk SUNO tracks defined here.
//  Audio files live in the Xcode bundle with matching id names.
//
//  TO ADD OR UPDATE A TRACK:
//  1. Change the title or durationSeconds here.
//  2. Drop the .mp3 / .m4a file into the project with the same id as filename.
//  Nothing else needs to change anywhere.
//
//  Normal pace: ~100 BPM, calm, instrumental
//  Brisk pace:  ~140 BPM, upbeat, instrumental
//  All tracks timed precisely — no cutoff at interval boundary.
//

import Foundation

enum SunoTrackLibrary {

    // ── Normal Pace ───────────────────────────────────────────────────
    static let normalTracks: [SunoTrack] = [
        SunoTrack(id: "normal_01", title: "Morning Path",     pace: .normal, durationSeconds: 180),
        SunoTrack(id: "normal_02", title: "Gentle Flow",      pace: .normal, durationSeconds: 180),
        SunoTrack(id: "normal_03", title: "Still Waters",     pace: .normal, durationSeconds: 180),
        SunoTrack(id: "normal_04", title: "Autumn Walk",      pace: .normal, durationSeconds: 180),
        SunoTrack(id: "normal_05", title: "Quiet Garden",     pace: .normal, durationSeconds: 180),
        SunoTrack(id: "normal_06", title: "Steady Breath",    pace: .normal, durationSeconds: 180),
        SunoTrack(id: "normal_07", title: "Open Road",        pace: .normal, durationSeconds: 180),
        SunoTrack(id: "normal_08", title: "River Stones",     pace: .normal, durationSeconds: 180),
        SunoTrack(id: "normal_09", title: "Late Morning",     pace: .normal, durationSeconds: 180),
        SunoTrack(id: "normal_10", title: "Peaceful Cadence", pace: .normal, durationSeconds: 180),
    ]

    // ── Brisk Pace ────────────────────────────────────────────────────
    static let briskTracks: [SunoTrack] = [
        SunoTrack(id: "brisk_01",  title: "Pick It Up",       pace: .brisk,  durationSeconds: 180),
        SunoTrack(id: "brisk_02",  title: "Forward March",    pace: .brisk,  durationSeconds: 180),
        SunoTrack(id: "brisk_03",  title: "Electric Step",    pace: .brisk,  durationSeconds: 180),
        SunoTrack(id: "brisk_04",  title: "Momentum",         pace: .brisk,  durationSeconds: 180),
        SunoTrack(id: "brisk_05",  title: "Push Through",     pace: .brisk,  durationSeconds: 180),
        SunoTrack(id: "brisk_06",  title: "Rising Energy",    pace: .brisk,  durationSeconds: 180),
        SunoTrack(id: "brisk_07",  title: "Strong Stride",    pace: .brisk,  durationSeconds: 180),
        SunoTrack(id: "brisk_08",  title: "Full Pace",        pace: .brisk,  durationSeconds: 180),
        SunoTrack(id: "brisk_09",  title: "Drive",            pace: .brisk,  durationSeconds: 180),
        SunoTrack(id: "brisk_10",  title: "Final Push",       pace: .brisk,  durationSeconds: 180),
    ]

    static var allTracks: [SunoTrack] { normalTracks + briskTracks }

    static func track(byId id: String) -> SunoTrack? {
        allTracks.first { $0.id == id }
    }
}
