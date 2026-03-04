//
//  BottomNavBar.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI

struct BottomNavBar: View {
    @Binding var selectedTab: Int
    var onTabReTap: (() -> Void)? = nil
    var onTabChange: ((Int) -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 56) {
            
            // WALK TAB
            TabBarItem(
                icon: "figure.walk",
                customIconName: nil,
                title: "Walk",
                isSelected: selectedTab == 0
            ) {
                if selectedTab == 0 {
                    // If we are already here, trigger the "Go Home" action
                    onTabReTap?()
                } else {
                    handleTabChange(to: 0)
                }
            }
            
            // Progress Tab
            TabBarItem(
                icon: "trophy.fill",
                customIconName: "TrophyIcon",
                title: "Progress",
                isSelected: selectedTab == 1
            ) {
                if selectedTab == 1 {
                    onTabReTap?()
                } else {
                    handleTabChange(to: 1)
                }
            }
            
            // Features Tab
            TabBarItem(
                icon: "person.fill",
                customIconName: nil,
                title: "Features",
                isSelected: selectedTab == 2
            ) {
                if selectedTab == 2 {
                    onTabReTap?()
                } else {
                    handleTabChange(to: 2)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.clear)
    }
    
    private func handleTabChange(to tab: Int) {
        if let handler = onTabChange {
            handler(tab)
        } else {
            selectedTab = tab
        }
    }
}

// TabBarItem
struct TabBarItem: View {
    let icon: String
    let customIconName: String?
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Circle is always in layout — opacity controls visibility.
                    // This prevents layout shifts that cause the visual jump.
                    Circle()
                        .fill(isoWalkColors.gradientBlue)
                        .shadow(
                            color: isoWalkColors.deepSpaceBlue.opacity(isSelected ? 0.4 : 0),
                            radius: 8, x: 0, y: 4
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(isSelected ? 0.3 : 0),
                                            Color.white.opacity(0.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .opacity(isSelected ? 1 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                    
                    
                    // AFTER:
                    if let assetName = customIconName, let _ = UIImage(named: assetName) {
                        Image(assetName)
                            .renderingMode(.template)   // ← guarantees template mode regardless of asset setting
                            .resizable()
                            .scaledToFit()
                            .frame(width: 42, height: 42)  
                            .foregroundColor(isSelected ? .white : isoWalkColors.deepSpaceBlue)
                    
                    } else {
                        
                        Image(systemName: icon)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(isSelected ? .white : isoWalkColors.deepSpaceBlue)
                    }
                }
                .frame(width: 56, height: 56)
                
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isoWalkColors.jetBlack)
            }
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    VStack(spacing: 40) {
        
        BottomNavBar(selectedTab: .constant(0))
        
        
        BottomNavBar(selectedTab: .constant(1))
        
        
        BottomNavBar(selectedTab: .constant(2))
    }
    .padding()
    .background(isoWalkColors.parchment)
}
