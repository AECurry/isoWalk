//
//  isoWalkThemes.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  isoWalk Design System
//
//  TO ADD A NEW THEME: add ONE AnimatedImageConfig entry to availableImages below.
//  Everything else picks it up automatically.
//

import SwiftUI

// ==========================================
// MARK: - SIZE ENUM
// ==========================================

enum AnimatedImageSize {
    case extraLarge  // 335x335 — Get Walking screen
    case medium      // 188x188 — Walk Set Up screen

    var dimension: CGFloat {
        switch self {
        case .extraLarge: return 335
        case .medium:     return 188
        }
    }
}

// ==========================================
// MARK: - ANIMATION ENUMS
// These tell your Engine exactly how to move!
// ==========================================

enum OverlayAnimation {
    case none
    case horizontalDrift(duration: Double)
    case pulse(minScale: CGFloat, maxScale: CGFloat, speed: Double)
    case rotate(speed: Double)
}

enum AnimationType {
    case none
    case rotation(speed: Double)
    case pulse(minScale: CGFloat, maxScale: CGFloat, speed: Double)
    case rotatingPulse(rotationSpeed: Double, minScale: CGFloat, maxScale: CGFloat, pulseSpeed: Double)
    case layeredAnimation(backgroundImage: String, overlayImage: String, overlayAnimation: OverlayAnimation)
    case video(name: String, fallbackImage: String)
}

// ==========================================
// MARK: - THEME MODEL (The Blueprint)
// ==========================================

struct IsoWalkTheme: Identifiable {

    let id: String
    let name: String
    let description: String
    
    var backgroundImageName: String?
    var backgroundColor: Color?
    var cardColor: Color
    
    
    var primaryTextColor: Color
    var secondaryTextColor: Color
    var titleFontName: String
    var bodyFontName: String
    
    var primaryIconColor: Color
    
    var logoImageName: String

    
    let mainImageName: String
    let animationType: AnimationType

    static let selectedThemeKey = "selectedThemeId"
    static let defaultThemeId = "koi"
    
    static func current(selectedId: String) -> IsoWalkTheme {
        return IsoWalkThemeLibrary.getTheme(byId: selectedId) ?? IsoWalkThemeLibrary.availableThemes[0]
    }
}

// ==========================================
// MARK: - LIBRARY (The Master List)
// ==========================================

struct IsoWalkThemeLibrary {

    static let availableThemes: [IsoWalkTheme] = [

        // ── Theme 1: Japanese Koi ──────────────────────────────────────
        IsoWalkTheme(
            id: "koi",
            name: "Japanese Koi",
            description: "Two koi swimming in harmony",
            
            backgroundImageName: "Themes/GoldenTextureBackground",
            backgroundColor: nil,
            cardColor: isoWalkColors.ivory,
            
            primaryTextColor: isoWalkColors.deepSpaceBlue,
            secondaryTextColor: isoWalkColors.slateGray,
            titleFontName: "Inter-Bold",
            bodyFontName: "Inter-SemiBold",
            
            primaryIconColor: isoWalkColors.deepSpaceBlue,
            
            logoImageName: "Logos/isoWalkLogo1",
            
            mainImageName: "Themes/JapaneseKoi",
            animationType: .rotatingPulse(rotationSpeed: 88.0, minScale: 1.0, maxScale: 1.08, pulseSpeed: 8.0)
        ),

        // ── Theme 2: Japanese Tree with Clouds ──────────────────────────
        IsoWalkTheme(
            id: "japaneseTree",
            name: "Japanese Tree",
            description: "A peaceful tree with drifting clouds",
            
            backgroundImageName: nil,
            backgroundColor: isoWalkColors.white,
            cardColor: isoWalkColors.silverMist,
            
            primaryTextColor: isoWalkColors.jetBlack,
            secondaryTextColor: isoWalkColors.slateGray,
            titleFontName: "Inter-Bold",
            bodyFontName: "Inter-SemiBold",
            
            primaryIconColor: isoWalkColors.deepSpaceBlue,
            
            logoImageName: "Logos/isoWalkLogo1",
            
            mainImageName: "Themes/JapaneseTreeWithClouds", // Fallback for screens without animation
            animationType: .layeredAnimation(
                backgroundImage: "Themes/JapaneseTreeWithClouds",
                overlayImage: "Themes/CloudSwirls",
                overlayAnimation: .horizontalDrift(duration: 72.0) // Your perfect slow drift!
            )
        ),
    ]

    static func getTheme(byId id: String) -> IsoWalkTheme? {
        availableThemes.first { $0.id == id }
    }
}

