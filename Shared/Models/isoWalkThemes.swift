//
//  IsoWalkThemes.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//
//  SOURCE OF TRUTH for all theme data.
//  To add a new theme: add ONE entry to AnimatedImageLibrary.availableImages
//  in AnimatedImageConfig.swift. Nothing else needs to change.
//

import SwiftUI

// ==========================================
// MARK: - ANIMATION TYPE
// ==========================================

enum ThemeAnimationType {
    case rotation(speed: Double)
    case pulse(minScale: Double, maxScale: Double, speed: Double)
    case rotatingPulse(rotSpeed: Double, minScale: Double, maxScale: Double, pulseSpeed: Double)
    case layeredAnimation(backgroundImage: String, overlayImage: String, overlayAnimation: OverlayAnimation)
    // NEW: Future-proofed for Kling AI videos (.mp4)
    case video(filename: String, fallbackImageName: String)
    case none
}

// Overlay animation types for layered themes
enum OverlayAnimation {
    case none // <--- ADDED: Strict "Do Not Animate" option for testing alignment
    case horizontalDrift(duration: Double)  // Clouds scrolling left to right
    case pulse(minScale: Double, maxScale: Double, speed: Double)
    case rotate(speed: Double)
}

// ==========================================
// MARK: - THEME MODEL (one theme)
// ==========================================

struct IsoWalkTheme: Identifiable {
    let id: String
    let displayName: String
    let mainImageName: String
    let logoImageName: String          // Hero image shown on FeaturesHomeScreen
    let backgroundImageName: String?
    let backgroundColor: Color
    let animationType: ThemeAnimationType

    // Built dynamically from config — NO MANUAL WIRING NEEDED. (Koi Fish uses this!)
    init(from config: AnimatedImageConfig) {
        self.id                  = config.id
        self.displayName         = config.name
        self.mainImageName       = config.imageName
        self.logoImageName       = config.logoImageName
        self.backgroundImageName = "GoldenTextureBackground"
        self.backgroundColor     = isoWalkColors.parchment

        if config.isRotationEnabled && config.isScaleEnabled {
            self.animationType = .rotatingPulse(
                rotSpeed:   config.rotationSpeed,
                minScale:   config.minScale,
                maxScale:   config.maxScale,
                pulseSpeed: config.scaleSpeed
            )
        } else if config.isRotationEnabled {
            self.animationType = .rotation(speed: config.rotationSpeed)
        } else if config.isScaleEnabled {
            self.animationType = .pulse(
                minScale: config.minScale,
                maxScale: config.maxScale,
                speed:    config.scaleSpeed
            )
        } else {
            self.animationType = .none
        }
    }
    
    // Custom initializer for layered animations and videos
    init(
        id: String,
        displayName: String,
        mainImageName: String,
        logoImageName: String,
        backgroundImageName: String? = "GoldenTextureBackground",
        backgroundColor: Color = isoWalkColors.parchment,
        animationType: ThemeAnimationType
    ) {
        self.id = id
        self.displayName = displayName
        self.mainImageName = mainImageName
        self.logoImageName = logoImageName
        self.backgroundImageName = backgroundImageName
        self.backgroundColor = backgroundColor
        self.animationType = animationType
    }
}

// ==========================================
// MARK: - ISOWALKSTHEMES (the full catalog)
// ==========================================

struct IsoWalkThemes {

    static var all: [IsoWalkTheme] {
        var themes = AnimatedImageLibrary.availableImages.map { IsoWalkTheme(from: $0) }
        
        // Add custom layered theme
        themes.append(cloudyTreeTheme)
        
        return themes
    }

    static func current(selectedId: String) -> IsoWalkTheme {
        all.first { $0.id == selectedId } ?? all[0]
    }

    static let selectedThemeKey = "selectedThemeId"
    static let defaultThemeId   = "koi"
    
    // Cloudy Tree Theme - CURRENTLY SET TO .none FOR ALIGNMENT TESTING
    static let cloudyTreeTheme = IsoWalkTheme(
        id: "cloudyTree",
        displayName: "Japanese Tree with Clouds",
        mainImageName: "JapaneseTreeWithClouds",
        logoImageName: "JapaneseTreeWithClouds",
        backgroundImageName: nil,  // No background image
        backgroundColor: .white,    // White background
        animationType: .layeredAnimation(
            backgroundImage: "JapaneseTreeWithClouds",
            overlayImage: "CloudSwirls",
            overlayAnimation: .none  // <--- SET TO .none FOR PURE ALIGNMENT TEST
        )
    )
}
