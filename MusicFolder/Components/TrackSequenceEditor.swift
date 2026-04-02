//
//  TrackSequenceEditor.swift
//  isoWalk
//
//  Created by AnnElaine on 3/12/26.
//
//
//  Full customization screen for isoWalk track sequences.
//  Allows users to select, reorder, and shuffle tracks for their walk.
//  Displays an interleaved playlist with clear, prominent pace titles above each track.
//

import SwiftUI

// MARK: - Helper Structs
struct TrackPickerContext: Identifiable {
    let id = UUID()
    let pace: WalkPaceTag
    let index: Int
}

struct OrderedTrack: Identifiable {
    let id = UUID()
    let displayIndex: Int
    let arrayIndex: Int
    let pace: WalkPaceTag
    let paceNumber: Int
    let trackId: String
    let duration: Int
    let isCooldown: Bool
}

struct TrackSequenceEditor: View {
    
    @Bindable var viewModel: MusicViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Using a single state variable for the sheet context
    @State private var activePickerContext: TrackPickerContext?
    
    private var sequence: TrackSequence? { viewModel.currentTrackSequence }
    private var cycleInfo: CycleInfo? { sequence?.cycleInfo }
    
    private var interleavedTracks: [OrderedTrack] {
        guard let seq = sequence, let info = cycleInfo else { return [] }
        var result: [OrderedTrack] = []
        
        let normalCount = seq.normalTrackIds.count
        let briskCount = seq.briskTrackIds.count
        let maxCount = max(normalCount, briskCount)
        
        var overallCounter = 1
        var normalCounter = 1
        var briskCounter = 1
        
        for i in 0..<maxCount {
            // 1. Add the Normal track for this cycle
            if i < normalCount {
                let isLastNormal = (i == normalCount - 1)
                let duration = isLastNormal ? info.finalNormalDuration : info.normalDuration
                let isCooldown = isLastNormal && info.cooldownExtension > 0
                
                result.append(OrderedTrack(
                    displayIndex: overallCounter,
                    arrayIndex: i,
                    pace: .normal,
                    paceNumber: normalCounter,
                    trackId: seq.normalTrackIds[i],
                    duration: duration,
                    isCooldown: isCooldown
                ))
                overallCounter += 1
                normalCounter += 1
            }
            
            // 2. Add the Brisk track for this cycle
            if i < briskCount {
                result.append(OrderedTrack(
                    displayIndex: overallCounter,
                    arrayIndex: i,
                    pace: .brisk,
                    paceNumber: briskCounter,
                    trackId: seq.briskTrackIds[i],
                    duration: info.briskDuration,
                    isCooldown: false
                ))
                overallCounter += 1
                briskCounter += 1
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                isoWalkColors.parchment.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Header info
                        if let seq = sequence {
                            headerSection(seq)
                        }
                        
                        // Playlist section with conversational headers
                        playlistSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 80)
                }
            }
            .navigationTitle("Customize Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(isoWalkColors.balticBlue)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.saveTrackSequence()
                        dismiss()
                    }
                    .foregroundColor(isoWalkColors.balticBlue)
                    .fontWeight(.semibold)
                }
            }
            .sheet(item: $activePickerContext) { context in
                if let seq = sequence {
                    let currentTrackId = context.pace == .normal
                        ? (seq.normalTrackIds.indices.contains(context.index) ? seq.normalTrackIds[context.index] : "")
                        : (seq.briskTrackIds.indices.contains(context.index) ? seq.briskTrackIds[context.index] : "")
                    
                    TrackSequencePicker(
                        pace: context.pace,
                        currentTrackId: currentTrackId,
                        onSelect: { trackId in
                            if context.pace == .normal {
                                viewModel.updateNormalTrack(at: context.index, trackId: trackId)
                            } else {
                                viewModel.updateBriskTrack(at: context.index, trackId: trackId)
                            }
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private func headerSection(_ seq: TrackSequence) -> some View {
        VStack(spacing: 8) {
            Text("\(seq.duration.displayName) Walk")
                .font(.custom("Inter-Bold", size: 20))
                .foregroundColor(isoWalkColors.jetBlack)
            
            if let info = cycleInfo {
                Text("\(seq.pace.ratioDisplay) pace • \(info.totalCycles) intervals")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(isoWalkColors.slateGray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // MARK: - Playlist Section
    
    private var playlistSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("PLAYLIST ORDER")
                    .font(.custom("Inter-Bold", size: 14))
                    .foregroundColor(isoWalkColors.slateGray)
                
                if let seq = sequence {
                    let totalTracks = seq.normalTrackIds.count + seq.briskTrackIds.count
                    Text("(\(totalTracks) tracks)")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(isoWalkColors.slateGray)
                }
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            // The list of tracks with their custom titles above them
            VStack(spacing: 24) {
                ForEach(interleavedTracks) { track in
                    VStack(alignment: .leading, spacing: 8) {
                        
                        // Simplified Title Header
                        trackTitleHeader(for: track)
                            .padding(.horizontal, 4)
                        
                        // The track card
                        trackRow(
                            displayIndex: track.displayIndex,
                            arrayIndex: track.arrayIndex,
                            trackId: track.trackId,
                            pace: track.pace,
                            duration: track.duration
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Title Builder
    
    @ViewBuilder
    private func trackTitleHeader(for track: OrderedTrack) -> some View {
        let titleText: String = {
            if track.isCooldown {
                return "Cooldown"
            } else {
                return track.pace == .normal ? "Normal Pace" : "Brisk Pace"
            }
        }()
        
        Text(titleText)
            .font(.custom("Inter-Bold", size: 16)) // Increased size and made it Bold
            .foregroundColor(isoWalkColors.balticBlue)
            // Added slight capitalization standard for titles
            .textCase(.uppercase)
    }
    
    // Helper to turn 1 into "first", 2 into "second", etc. (Kept in case you need it elsewhere, but no longer used in titles)
    private func numberToOrdinal(_ number: Int) -> String {
        let ordinals = ["first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth", "eleventh", "twelfth"]
        if number > 0 && number <= ordinals.count {
            return ordinals[number - 1]
        }
        return "\(number)th"
    }
    
    // MARK: - Track Row (Simplified)
    
    private func trackRow(
        displayIndex: Int,
        arrayIndex: Int,
        trackId: String,
        pace: WalkPaceTag,
        duration: Int
    ) -> some View {
        HStack(spacing: 12) {
            // Index number
            Text("\(displayIndex)")
                .font(.custom("Inter-SemiBold", size: 16))
                .foregroundColor(isoWalkColors.slateGray)
                .frame(width: 24)
            
            // Track info
            VStack(alignment: .leading, spacing: 4) {
                if let track = SunoTrackLibrary.track(byId: trackId) {
                    Text(track.title)
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(isoWalkColors.jetBlack)
                    
                    Text("\(duration) min")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(isoWalkColors.slateGray)
                }
            }
            
            Spacer()
            
            // Drag handle / Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 16))
                .foregroundColor(isoWalkColors.slateGray)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            activePickerContext = TrackPickerContext(pace: pace, index: arrayIndex)
        }
    }
}

#Preview {
    let vm = MusicViewModel()
    vm.loadTrackSequence(pace: .steady, duration: .thirty)
    return TrackSequenceEditor(viewModel: vm)
}

