//
//  SunoTrackLibrary.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//  Updated 3/12/26: Added real SUNO tracks with duration-specific filenames
//
//  Library of all bundled isoWalk tracks created by SUNO AI.
//  10 Normal pace tracks + 10 Brisk pace tracks.
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
        
        // REAL TRACKS (created in SUNO)
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
        ),
        
        // PLACEHOLDER TRACKS (replace when you create them)
        SunoTrack(
            id: "normal_03",
            title: "Morning Path",
            baseFilename: "Morning Path (Placeholder_Normal_110",
            pace: .normal,
            bpm: 110,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "normal_04",
            title: "Gentle Flow",
            baseFilename: "Gentle Flow (Placeholder_Normal_108",
            pace: .normal,
            bpm: 108,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "normal_05",
            title: "Still Waters",
            baseFilename: "Still Waters (Placeholder_Normal_105",
            pace: .normal,
            bpm: 105,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "normal_06",
            title: "Autumn Walk",
            baseFilename: "Autumn Walk (Placeholder_Normal_112",
            pace: .normal,
            bpm: 112,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "normal_07",
            title: "Quiet Garden",
            baseFilename: "Quiet Garden (Placeholder_Normal_108",
            pace: .normal,
            bpm: 108,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "normal_08",
            title: "Steady Breath",
            baseFilename: "Steady Breath (Placeholder_Normal_110",
            pace: .normal,
            bpm: 110,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "normal_09",
            title: "Open Road",
            baseFilename: "Open Road (Placeholder_Normal_115",
            pace: .normal,
            bpm: 115,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "normal_10",
            title: "River Stones",
            baseFilename: "River Stones (Placeholder_Normal_108",
            pace: .normal,
            bpm: 108,
            style: "Placeholder"
        ),
    ]
    
    // ==========================================
    // MARK: - BRISK PACE TRACKS
    // ==========================================
    
    static let briskTracks: [SunoTrack] = [
        
        // PLACEHOLDER TRACKS (replace when you create them)
        SunoTrack(
            id: "brisk_01",
            title: "City Stride",
            baseFilename: "City Stride (Placeholder_Brisk_128",
            pace: .brisk,
            bpm: 128,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "brisk_02",
            title: "Mountain Climb",
            baseFilename: "Mountain Climb (Placeholder_Brisk_130",
            pace: .brisk,
            bpm: 130,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "brisk_03",
            title: "Power Hour",
            baseFilename: "Power Hour (Placeholder_Brisk_132",
            pace: .brisk,
            bpm: 132,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "brisk_04",
            title: "Fast Lane",
            baseFilename: "Fast Lane (Placeholder_Brisk_135",
            pace: .brisk,
            bpm: 135,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "brisk_05",
            title: "Energy Boost",
            baseFilename: "Energy Boost (Placeholder_Brisk_128",
            pace: .brisk,
            bpm: 128,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "brisk_06",
            title: "Sprint Forward",
            baseFilename: "Sprint Forward (Placeholder_Brisk_130",
            pace: .brisk,
            bpm: 130,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "brisk_07",
            title: "Peak Push",
            baseFilename: "Peak Push (Placeholder_Brisk_132",
            pace: .brisk,
            bpm: 132,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "brisk_08",
            title: "Uphill Battle",
            baseFilename: "Uphill Battle (Placeholder_Brisk_128",
            pace: .brisk,
            bpm: 128,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "brisk_09",
            title: "Chase Horizon",
            baseFilename: "Chase Horizon (Placeholder_Brisk_135",
            pace: .brisk,
            bpm: 135,
            style: "Placeholder"
        ),
        
        SunoTrack(
            id: "brisk_10",
            title: "Final Mile",
            baseFilename: "Final Mile (Placeholder_Brisk_130",
            pace: .brisk,
            bpm: 130,
            style: "Placeholder"
        ),
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
