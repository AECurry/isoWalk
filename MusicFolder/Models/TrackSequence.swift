//
//  TrackSequence.swift
//  isoWalk
//
//  Created by AnnElaine on 3/12/26.
//
//
//  Data model for isoWalk Tracks playlists.
//  Stores user's track selections per pace/duration combo.
//  Persists all 15 combinations (3 paces × 5 durations).
//

import Foundation

// ─────────────────────────────────────────
// MARK: - Track Sequence Model
// ─────────────────────────────────────────

struct TrackSequence: Codable, Identifiable {
    let id: String                  // Computed key: "leisurely_thirty"
    let pace: PaceOptions
    let duration: DurationOptions
    var normalTrackIds: [String]    // Ordered array of track IDs
    var briskTrackIds: [String]     // Ordered array of track IDs
    var lastModified: Date
    
    // MARK: - Computed Properties
    
    var cycleInfo: CycleInfo {
        duration.cycleInfo(for: pace)
    }
    
    var isComplete: Bool {
        let info = cycleInfo
        return normalTrackIds.count == info.normalCount
            && briskTrackIds.count == info.briskCount
            && !normalTrackIds.contains("")
            && !briskTrackIds.contains("")
    }
    
    // Full alternating playback sequence: N-B-N-B-N-B-N
    var playbackSequence: [TrackSequenceItem] {
        var sequence: [TrackSequenceItem] = []
        let info = cycleInfo
        
        // Add alternating N-B pairs (all except last Normal)
        for i in 0..<info.briskCount {
            // Normal interval
            if i < normalTrackIds.count,
               let track = SunoTrackLibrary.track(byId: normalTrackIds[i]) {
                sequence.append(TrackSequenceItem(
                    intervalNumber: sequence.count + 1,
                    track: track,
                    durationMinutes: info.normalDuration
                ))
            }
            
            // Brisk interval
            if i < briskTrackIds.count,
               let track = SunoTrackLibrary.track(byId: briskTrackIds[i]) {
                sequence.append(TrackSequenceItem(
                    intervalNumber: sequence.count + 1,
                    track: track,
                    durationMinutes: info.briskDuration
                ))
            }
        }
        
        // Add final Normal interval (potentially extended for cooldown)
        if let lastNormalId = normalTrackIds.last,
           let track = SunoTrackLibrary.track(byId: lastNormalId) {
            sequence.append(TrackSequenceItem(
                intervalNumber: sequence.count + 1,
                track: track,
                durationMinutes: info.finalNormalDuration,
                isCooldown: info.cooldownExtension > 0
            ))
        }
        
        return sequence
    }
    
    // MARK: - Initialization
    
    init(pace: PaceOptions, duration: DurationOptions) {
        self.id = "\(pace.rawValue)_\(duration.rawValue)"
        self.pace = pace
        self.duration = duration
        self.normalTrackIds = []
        self.briskTrackIds = []
        self.lastModified = Date()
    }
}

// ─────────────────────────────────────────
// MARK: - Track Sequence Item (for playback)
// ─────────────────────────────────────────

struct TrackSequenceItem: Identifiable {
    let id = UUID()
    let intervalNumber: Int         // 1, 2, 3...
    let track: SunoTrack
    let durationMinutes: Int        // Actual interval duration
    var isCooldown: Bool = false    // True if this is the extended final Normal
    
    var displayDuration: String {
        "\(durationMinutes) min"
    }
    
    var paceLabel: String {
        track.pace == .normal ? "N" : "B"
    }
}

// ─────────────────────────────────────────
// MARK: - Track Sequence Storage
// ─────────────────────────────────────────

struct TrackSequenceStorage {
    
    private static let storageKey = "savedTrackSequences"
    
    // MARK: - Public Interface
    
    /// Get sequence for a pace/duration combo. Creates default if doesn't exist.
    static func getOrCreate(pace: PaceOptions, duration: DurationOptions) -> TrackSequence {
        if let saved = load(pace: pace, duration: duration) {
            return saved
        }
        return createDefault(pace: pace, duration: duration)
    }
    
    /// Save a track sequence
    static func save(_ sequence: TrackSequence) {
        var all = loadAll()
        var updated = sequence
        updated.lastModified = Date()
        all[sequence.id] = updated
        saveAll(all)
    }
    
    /// Load a specific sequence
    static func load(pace: PaceOptions, duration: DurationOptions) -> TrackSequence? {
        let key = "\(pace.rawValue)_\(duration.rawValue)"
        return loadAll()[key]
    }
    
    /// Delete a specific sequence (reset to default)
    static func delete(pace: PaceOptions, duration: DurationOptions) {
        let key = "\(pace.rawValue)_\(duration.rawValue)"
        var all = loadAll()
        all.removeValue(forKey: key)
        saveAll(all)
    }
    
    /// Clear all saved sequences
    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    // MARK: - Private Helpers
    
    private static func loadAll() -> [String: TrackSequence] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let sequences = try? JSONDecoder().decode([String: TrackSequence].self, from: data)
        else { return [:] }
        return sequences
    }
    
    private static func saveAll(_ sequences: [String: TrackSequence]) {
        if let data = try? JSONEncoder().encode(sequences) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    /// Create a default sequence using the first track from each library
    private static func createDefault(pace: PaceOptions, duration: DurationOptions) -> TrackSequence {
        var sequence = TrackSequence(pace: pace, duration: duration)
        let info = duration.cycleInfo(for: pace)
        
        // Fill Normal slots with first Normal track
        if let firstNormal = SunoTrackLibrary.normalTracks.first {
            sequence.normalTrackIds = Array(repeating: firstNormal.id, count: info.normalCount)
        }
        
        // Fill Brisk slots with first Brisk track
        if let firstBrisk = SunoTrackLibrary.briskTracks.first {
            sequence.briskTrackIds = Array(repeating: firstBrisk.id, count: info.briskCount)
        }
        
        return sequence
    }
}

