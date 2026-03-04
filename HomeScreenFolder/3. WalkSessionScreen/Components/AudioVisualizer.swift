//
//  AudioVisualizer.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Displays animated audio visualizer bars during walk session.
//  Receives amplitude data and active state from parent — owns nothing.
//

import SwiftUI

struct AudioVisualizer: View {
    let amplitudes: [Float]
    let isActive: Bool

    private var normalizedAmplitudes: [CGFloat] {
        amplitudes.map { CGFloat($0) }
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<30, id: \.self) { index in
                VisualizerBar(
                    amplitude: normalizedAmplitudes[index],
                    isActive: isActive
                )
            }
        }
        .frame(height: 60)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

struct VisualizerBar: View {
    let amplitude: CGFloat
    let isActive: Bool

    @State private var currentHeight: CGFloat = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                isActive
                    ? isoWalkColors.balticBlue
                    : isoWalkColors.deepSpaceBlue.opacity(0.3)
            )
            .frame(width: 4, height: currentHeight)
            .onAppear {
                currentHeight = 1
                animateBar()
            }
            .onChange(of: amplitude) { _, _ in animateBar() }
            .onChange(of: isActive) { _, newValue in
                if !newValue {
                    withAnimation(.easeOut(duration: 0.3)) { currentHeight = 1 }
                } else {
                    animateBar()
                }
            }
    }

    private func animateBar() {
        guard isActive else { return }
        let targetHeight = max(1, amplitude * 50)
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
            currentHeight = targetHeight
        }
    }
}

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        VStack(spacing: 32) {
            AudioVisualizer(amplitudes: Array(repeating: 0.5, count: 30), isActive: true)
            AudioVisualizer(amplitudes: Array(repeating: 0.1, count: 30), isActive: false)
        }
    }
}

