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

    // MARK: - Derived: selection summary for collapsed card
    var selectedMode: MusicMode { selection.mode }

    var summaryLabel: String {
        switch selection.mode {
        case .noMusic:
            return "No Music"
        case .isoWalkTracks:
            let n = SunoTrackLibrary.track(byId: selection.selectedNormalTrackId ?? "")?.title ?? "None"
            let b = SunoTrackLibrary.track(byId: selection.selectedBriskTrackId  ?? "")?.title ?? "None"
            return "\(n) · \(b)"
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
            return selection.selectedNormalTrackId != nil
                && selection.selectedBriskTrackId  != nil
        case .myMusic:
            return selection.isValidForMyMusic
        }
    }

    var validationMessage: String? { selection.validationMessage }

    // MARK: - isoWalk Tracks
    var normalTracks: [SunoTrack] { SunoTrackLibrary.normalTracks }
    var briskTracks:  [SunoTrack] { SunoTrackLibrary.briskTracks  }

    func selectNormalTrack(_ track: SunoTrack) {
        selection.selectedNormalTrackId = track.id
        save()
    }

    func selectBriskTrack(_ track: SunoTrack) {
        selection.selectedBriskTrackId = track.id
        save()
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
