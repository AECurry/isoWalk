//
//  TrackSequenceEditor.swift
//  isoWalk
//
//  Created by AnnElaine on 3/12/26.
//
//
//  Full customization screen for isoWalk track sequences.
//  Allows users to select, reorder, and shuffle tracks for their walk.
//  Displays separate sections for Normal and Brisk intervals.
//

import SwiftUI

// MARK: - Helper Struct for Sheet Presentation
struct TrackPickerContext: Identifiable {
    let id = UUID()
    let pace: WalkPaceTag
    let index: Int
}

struct TrackSequenceEditor: View {
    
    @Bindable var viewModel: MusicViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Using a single state variable for the sheet context
    @State private var activePickerContext: TrackPickerContext?
    
    private var sequence: TrackSequence? { viewModel.currentTrackSequence }
    private var cycleInfo: CycleInfo? { sequence?.cycleInfo }
    
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
                        
                        // Normal tracks section
                        normalTracksSection
                        
                        // Brisk tracks section
                        briskTracksSection
                        
                        Spacer(minLength: 40)  // Extra padding at bottom
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
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
            // Updated to use .sheet(item:)
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
    
    // MARK: - Normal Tracks Section
    
    private var normalTracksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("NORMAL PACE")
                    .font(.custom("Inter-Bold", size: 14))
                    .foregroundColor(isoWalkColors.slateGray)
                
                if let count = cycleInfo?.normalCount {
                    Text("(\(count) tracks)")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(isoWalkColors.slateGray)
                }
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                if let seq = sequence, let info = cycleInfo {
                    ForEach(Array(seq.normalTrackIds.enumerated()), id: \.offset) { index, trackId in
                        trackRow(
                            index: index,
                            trackId: trackId,
                            pace: .normal,
                            duration: index == seq.normalTrackIds.count - 1
                                ? info.finalNormalDuration
                                : info.normalDuration,
                            isCooldown: index == seq.normalTrackIds.count - 1 && info.cooldownExtension > 0
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Brisk Tracks Section
    
    private var briskTracksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("BRISK PACE")
                    .font(.custom("Inter-Bold", size: 14))
                    .foregroundColor(isoWalkColors.slateGray)
                
                if let count = cycleInfo?.briskCount {
                    Text("(\(count) tracks)")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(isoWalkColors.slateGray)
                }
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                if let seq = sequence, let info = cycleInfo {
                    ForEach(Array(seq.briskTrackIds.enumerated()), id: \.offset) { index, trackId in
                        trackRow(
                            index: index,
                            trackId: trackId,
                            pace: .brisk,
                            duration: info.briskDuration,
                            isCooldown: false
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Track Row
    
    private func trackRow(
        index: Int,
        trackId: String,
        pace: WalkPaceTag,
        duration: Int,
        isCooldown: Bool
    ) -> some View {
        HStack(spacing: 12) {
            // Index number
            Text("\(index + 1)")
                .font(.custom("Inter-SemiBold", size: 16))
                .foregroundColor(isoWalkColors.slateGray)
                .frame(width: 24)
            
            // Track info
            VStack(alignment: .leading, spacing: 4) {
                if let track = SunoTrackLibrary.track(byId: trackId) {
                    Text(track.title)
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(isoWalkColors.jetBlack)
                    
                    HStack(spacing: 8) {
                        Text("\(duration) min")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(isoWalkColors.slateGray)
                        
                        if isCooldown {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                Text("cooldown")
                                    .font(.custom("Inter-Medium", size: 12))
                            }
                            .foregroundColor(isoWalkColors.balticBlue)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 16))
                .foregroundColor(isoWalkColors.slateGray)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            // Updated to immediately set the context, triggering the sheet
            activePickerContext = TrackPickerContext(pace: pace, index: index)
        }
    }
}

#Preview {
    let vm = MusicViewModel()
    vm.loadTrackSequence(pace: .steady, duration: .thirty)
    return TrackSequenceEditor(viewModel: vm)
}

