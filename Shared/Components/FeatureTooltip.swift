//
//  FeatureTooltip.swift
//  isoWalk
//
//  Created by AnnElaine on 4/3/26.
//
//  One-time feature discovery tooltips that appear next to hidden features.
//

import SwiftUI

struct FeatureTooltip: View {
    let message: String
    let position: TooltipPosition
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    enum TooltipPosition {
        case topLeading
        case topTrailing
        case bottom
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(message)
                    .font(.custom("Inter-Medium", size: 14))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onDismiss()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 20))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isoWalkColors.deepSpaceBlue)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .frame(maxWidth: 280)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.8)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}

// MARK: - FeatureTooltip.swift

struct FeatureTooltipManager {
    
    static func shouldShow(_ featureKey: String) -> Bool {
        let launchCount = UserDefaults.standard.integer(forKey: "appLaunchCount")
        let key = "lastSeenMilestone_\(featureKey)"
        let lastSeen = UserDefaults.standard.integer(forKey: key)
        
        // 1. Milestone: 2nd Launch
        // We show it if we are on launch #2 AND we haven't recorded seeing milestone 2 yet.
        if launchCount == 2 && lastSeen < 2 {
            return true
        }
        
        // 2. Milestone: 30th Launch
        // We show it if we are on launch #30 AND we haven't recorded seeing milestone 30 yet.
        if launchCount == 30 && lastSeen < 30 {
            return true
        }
        
        return false
    }
    
    static func markAsSeen(_ featureKey: String) {
        let launchCount = UserDefaults.standard.integer(forKey: "appLaunchCount")
        let key = "lastSeenMilestone_\(featureKey)"
        
        // Record that they've seen the tooltip for this specific launch count
        UserDefaults.standard.set(launchCount, forKey: key)
    }
}

