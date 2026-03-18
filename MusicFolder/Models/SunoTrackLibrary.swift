//
//  SunoTrackLibrary.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  Library of all bundled isoWalk tracks created by SUNO AI.
//
//  FOLDER STRUCTURE:
//  isoWalk/Shared/Audio/NormalPace/3mins/
//  isoWalk/Shared/Audio/NormalPace/4mins/
//  isoWalk/Shared/Audio/NormalPace/5mins/
//  isoWalk/Shared/Audio/BriskPace/1min/
//  isoWalk/Shared/Audio/BriskPace/2mins/
//  isoWalk/Shared/Audio/BriskPace/3mins/
//

import Foundation

struct SunoTrackLibrary {
    
    // ==========================================
    // MARK: - NORMAL PACE TRACKS
    // ==========================================
    
    static let normalTracks: [SunoTrack] = [
        
        SunoTrack(
            id: "normal_01",
            title: "Quiet Morning Alone",
            baseFilename: "Quiet Morning Alone (Jane Austen_Normal_112",
            pace: .normal,
            bpm: 112,
            style: "Jane Austen"
        ),
        
        SunoTrack(
            id: "normal_02",
            title: "Quiet Morning Stroll",
            baseFilename: "Quiet Morning Stroll (Jane Austen_Normal_112",
            pace: .normal,
            bpm: 112,
            style: "Jane Austen"
        )
    ]
    
    // ==========================================
    // MARK: - BRISK PACE TRACKS
    // ==========================================
    
    static let briskTracks: [SunoTrack] = [
        
        SunoTrack(
            id: "brisk_01",
            title: "Regency Reel",
            baseFilename: "RegencyReel(Brisk_132 BPM",
            pace: .brisk,
            bpm: 132,
            style: "Regency"
        ),
        
        SunoTrack(
            id: "brisk_02",
            title: "The Meryton Assembly",
            baseFilename: "The Meryton Assembly (Brisk_130 BPM",
            pace: .brisk,
            bpm: 130,
            style: "Regency"
        )
    ]
    
    // ==========================================
    // MARK: - HELPER METHODS
    // ==========================================
    
    static func track(byId id: String) -> SunoTrack? {
        let allTracks = normalTracks + briskTracks
        return allTracks.first { $0.id == id }
    }
    
    static func tracks(forPace pace: WalkPaceTag) -> [SunoTrack] {
        pace == .normal ? normalTracks : briskTracks
    }
}

