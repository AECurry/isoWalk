//
//  MusicPlayerService.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  Handles all audio playback for isoWalk.
//  Completely separate from ViewModels — no UI logic here.
//
//  ── isoWalk Tracks (SUNO) ──────────────────────────────────────────
//  Uses AVFoundation to play bundled .mp3 / .m4a files.
//  WalkSessionView calls playNormalTrack() / playBriskTrack()
//  in sync with the interval timer.
//
//  ── My Music (Apple Music) ─────────────────────────────────────────
//  Uses MusicKit (iOS 15+). Requires MusicKit entitlement in Xcode:
//  Target → Signing & Capabilities → + Capability → MusicKit
//  User is prompted for library access once on first use.
//
//  ── My Music (Spotify) ─────────────────────────────────────────────
//  Uses Spotify iOS SDK (SpotifyiOS Swift Package).
//  Requires Spotify Premium on the user's account.
//  Requires a Spotify Developer app registration at developer.spotify.com.
//  Add client ID to Info.plist key: SpotifyClientID
//
//  ── Next Sprint ────────────────────────────────────────────────────
//  TODO: Implement playTrack(_ sunoTrack: SunoTrack)
//  TODO: Implement requestAppleMusicAccess() → MusicKit authorization
//  TODO: Implement presentAppleMusicPicker() → MPMediaPickerController
//  TODO: Implement connectSpotify() → SPTSessionManager handshake
//  TODO: Implement onSongEnd callback → signals MusicViewModel to advance
//  TODO: Implement fadeOut(duration:) for smooth interval transitions
//  TODO: Implement chimeAndVoiceCue(for pace: WalkPaceTag)
//

import Foundation
import AVFoundation

@Observable
final class MusicPlayerService {

    // MARK: - State (observable by WalkSessionView)
    var isPlaying: Bool         = false
    var currentTrackTitle: String = ""
    var currentPace: WalkPaceTag  = .normal

    // Callback — called when a song ends (My Music mode)
    // WalkSessionView sets this to advance to the next song
    var onSongDidEnd: (() -> Void)?

    // MARK: - Private
    private var audioPlayer: AVAudioPlayer?

    // ── isoWalk Tracks ───────────────────────────────────────────────

    func playNormalTrack(_ track: SunoTrack) {
        // TODO: load track.id from bundle and play via AVAudioPlayer
        currentTrackTitle = track.title
        currentPace       = .normal
        isPlaying         = true
        print("[MusicPlayerService] Playing normal track: \(track.title)")
    }

    func playBriskTrack(_ track: SunoTrack) {
        // TODO: load track.id from bundle and play via AVAudioPlayer
        currentTrackTitle = track.title
        currentPace       = .brisk
        isPlaying         = true
        print("[MusicPlayerService] Playing brisk track: \(track.title)")
    }

    // ── My Music ─────────────────────────────────────────────────────

    func playSong(_ song: TaggedSong) {
        // TODO: route to MusicKit or Spotify based on MusicSelection.musicService
        currentTrackTitle = song.title
        currentPace       = song.paceTag
        isPlaying         = true
        print("[MusicPlayerService] Playing song: \(song.title) (\(song.paceTag.displayName))")
    }

    // ── Playback Control ─────────────────────────────────────────────

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func resume() {
        audioPlayer?.play()
        isPlaying = true
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer          = nil
        isPlaying            = false
        currentTrackTitle    = ""
    }

    func fadeOut(duration: TimeInterval = 2.0, completion: (() -> Void)? = nil) {
        // TODO: gradually reduce audioPlayer.volume to 0 then stop
        stop()
        completion?()
    }

    // ── Cues ─────────────────────────────────────────────────────────

    func playPaceCue(for pace: WalkPaceTag) {
        // TODO: play chime audio file, then AVSpeechSynthesizer voice cue
        let message = pace == .brisk
            ? "Time to pick up the pace."
            : "Slow it down. Nice and steady."
        print("[MusicPlayerService] Cue: \(message)")
    }
}
