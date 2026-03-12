//
//  IsoWalkTracksTab.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  Entry point for isoWalk Tracks mode.
//  Shows "We've created a playlist" message with customize option.
//  Loads track sequence based on selected pace/duration from WalkSetUpViewModel.
//

import SwiftUI

struct IsoWalkTracksTab: View {
    
    @Bindable var viewModel: MusicViewModel
    @State private var showingEditor = false
    
    // We need pace and duration from WalkSetUpViewModel
    // For now, using default values - these will be passed in from parent
    var selectedPace: PaceOptions = .steady
    var selectedDuration: DurationOptions = .thirty
    
    private var sequence: TrackSequence? { viewModel.currentTrackSequence }
    
    var body: some View {
        VStack(spacing: 20) {
            
            if let seq = sequence {
                // Playlist created message
                playlistCreatedSection(seq)
                
                // Quick stats
                statsSection(seq)
                
                // Action buttons
                actionButtons
                
            } else {
                // Loading state
                ProgressView()
                    .tint(.white)
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .onAppear {
            // Load or create sequence for current pace/duration
            viewModel.loadTrackSequence(pace: selectedPace, duration: selectedDuration)
        }
        .sheet(isPresented: $showingEditor) {
            TrackSequenceEditor(viewModel: viewModel)
        }
    }
    
    // MARK: - Playlist Created Section
    
    private func playlistCreatedSection(_ seq: TrackSequence) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
            
            Text("✨ We've created a playlist for you")
                .font(.custom("Inter-Bold", size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Your \(seq.duration.displayName) walk (\(seq.pace.ratioDisplay) pace)")
                .font(.custom("Inter-Regular", size: 15))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Stats Section
    
    private func statsSection(_ seq: TrackSequence) -> some View {
        HStack(spacing: 24) {
            statItem(
                icon: "figure.walk",
                value: "\(seq.cycleInfo.normalCount)",
                label: "Normal"
            )
            
            Divider()
                .frame(height: 40)
                .overlay(Color.white.opacity(0.2))
            
            statItem(
                icon: "figure.run",
                value: "\(seq.cycleInfo.briskCount)",
                label: "Brisk"
            )
            
            Divider()
                .frame(height: 40)
                .overlay(Color.white.opacity(0.2))
            
            statItem(
                icon: "music.note",
                value: "\(seq.cycleInfo.totalCycles)",
                label: "Tracks"
            )
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
    
    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.custom("Inter-Bold", size: 20))
                .foregroundColor(.white)
            
            Text(label)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Customize button
            Button(action: {
                showingEditor = true
            }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16))
                    Text("Customize Playlist")
                        .font(.custom("Inter-SemiBold", size: 16))
                }
                .foregroundColor(isoWalkColors.balticBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    ZStack {
        isoWalkColors.balticBlue.ignoresSafeArea()
        
        IsoWalkTracksTab(
            viewModel: MusicViewModel(),
            selectedPace: .steady,
            selectedDuration: .thirty
        )
    }
}

