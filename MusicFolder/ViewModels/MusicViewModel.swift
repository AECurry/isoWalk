//
//  MusicViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  Owns all music selection state for the entire app.
//  Shared between WalkSetUpScreen (picking) and
//  WalkSessionView (playing via MusicPlayerService).
//
//  Views are dumb — they read from and call into this only.
//  MusicPlayerService handles all actual audio operations.
//

import SwiftUI
import Observation

@Observable
final class MusicViewModel {

    // MARK: - State
    var selection: MusicSelection = MusicSelection.load()
    var activeTab: MusicMode      = .noMusic
    
    // NEW: Track sequence for isoWalk Tracks mode
    var currentTrackSequence: TrackSequence?
    var isEditingTrackSequence: Bool = false

    // MARK: - Derived: selection summary for collapsed card
    var selectedMode: MusicMode { selection.mode }

    var summaryLabel: String {
        switch selection.mode {
        case .noMusic:
            return "No Music"
        case .isoWalkTracks:
            if let sequence = currentTrackSequence, sequence.isComplete {
                return "Custom Playlist"
            }
            return "isoWalk Tracks"
        case .myMusic:
            if selection.taggedSongs.isEmpty { return "No songs added" }
            return selection.totalSessionDisplay
        }
    }

    var canStartWalk: Bool {
        switch selection.mode {
        case .noMusic:
            return true
        case .isoWalkTracks:
            // Must have valid track sequence
            guard let sequence = currentTrackSequence else { return false }
            return sequence.isComplete
        case .myMusic:
            return selection.isValidForMyMusic
        }
    }

    var validationMessage: String? {
        switch selection.mode {
        case .noMusic, .isoWalkTracks:
            return nil
        case .myMusic:
            return selection.validationMessage
        }
    }

    // MARK: - isoWalk Tracks (SUNO)
    var normalTracks: [SunoTrack] { SunoTrackLibrary.normalTracks }
    var briskTracks:  [SunoTrack] { SunoTrackLibrary.briskTracks  }

    // Load or create track sequence for current pace/duration
    func loadTrackSequence(pace: PaceOptions, duration: DurationOptions) {
        currentTrackSequence = TrackSequenceStorage.getOrCreate(pace: pace, duration: duration)
    }
    
    // Save current track sequence
    func saveTrackSequence() {
        guard let sequence = currentTrackSequence else { return }
        TrackSequenceStorage.save(sequence)
    }
    
    // Update a Normal track at specific index
    func updateNormalTrack(at index: Int, trackId: String) {
        guard var sequence = currentTrackSequence,
              index < sequence.normalTrackIds.count else { return }
        sequence.normalTrackIds[index] = trackId
        currentTrackSequence = sequence
        saveTrackSequence()
    }
    
    // Update a Brisk track at specific index
    func updateBriskTrack(at index: Int, trackId: String) {
        guard var sequence = currentTrackSequence,
              index < sequence.briskTrackIds.count else { return }
        sequence.briskTrackIds[index] = trackId
        currentTrackSequence = sequence
        saveTrackSequence()
    }
    
    // Reorder Normal tracks
    func moveNormalTrack(from source: IndexSet, to destination: Int) {
        guard var sequence = currentTrackSequence else { return }
        sequence.normalTrackIds.move(fromOffsets: source, toOffset: destination)
        currentTrackSequence = sequence
        saveTrackSequence()
    }
    
    // Reorder Brisk tracks
    func moveBriskTrack(from source: IndexSet, to destination: Int) {
        guard var sequence = currentTrackSequence else { return }
        sequence.briskTrackIds.move(fromOffsets: source, toOffset: destination)
        currentTrackSequence = sequence
        saveTrackSequence()
    }
    
    // Shuffle Normal tracks
    func shuffleNormalTracks() {
        guard var sequence = currentTrackSequence else { return }
        let shuffled = normalTracks.shuffled().prefix(sequence.normalTrackIds.count)
        sequence.normalTrackIds = shuffled.map { $0.id }
        currentTrackSequence = sequence
        saveTrackSequence()
    }
    
    // Shuffle Brisk tracks
    func shuffleBriskTracks() {
        guard var sequence = currentTrackSequence else { return }
        let shuffled = briskTracks.shuffled().prefix(sequence.briskTrackIds.count)
        sequence.briskTrackIds = shuffled.map { $0.id }
        currentTrackSequence = sequence
        saveTrackSequence()
    }

    // MARK: - My Music
    func setService(_ service: MusicService) {
        selection.musicService = service
        save()
    }

    func addSong(_ song: TaggedSong) {
        guard !selection.taggedSongs.contains(where: { $0.id == song.id }) else { return }
        selection.taggedSongs.append(song)
        save()
    }

    func removeSong(id: String) {
        selection.taggedSongs.removeAll { $0.id == id }
        save()
    }

    func togglePaceTag(id: String) {
        guard let idx = selection.taggedSongs.firstIndex(where: { $0.id == id }) else { return }
        selection.taggedSongs[idx].paceTag =
            selection.taggedSongs[idx].paceTag == .normal ? .brisk : .normal
        save()
    }

    func moveSong(from source: IndexSet, to destination: Int) {
        selection.taggedSongs.move(fromOffsets: source, toOffset: destination)
        save()
    }

    // MARK: - Mode
    func setMode(_ mode: MusicMode) {
        selection.mode = mode
        activeTab = mode
        save()
    }

    // MARK: - Persistence
    private func save() { selection.save() }
}

