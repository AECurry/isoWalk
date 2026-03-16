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
//  CONTAINS:
//  - ThemeAnimationType    → animation styles a theme can have
//  - IsoWalkTheme          → model for ONE theme
//  - IsoWalkThemes         → catalog of ALL themes + helper methods
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
    case none
}

// NEW: Overlay animation types for layered themes
enum OverlayAnimation {
    case drift(xOffset: CGFloat, yOffset: CGFloat, duration: Double)  // Clouds drifting
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

    // Built dynamically from config — no manual wiring needed.
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
    
    // NEW: Custom initializer for layered animations
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
    
    // NEW: Cloudy Tree Theme
    static let cloudyTreeTheme = IsoWalkTheme(
        id: "cloudyTree",
        displayName: "Japanese Tree with Clouds",
        mainImageName: "JapaneseTreeWithClouds",  // Fixed background
        logoImageName: "JapaneseTreeWithClouds",
        animationType: .layeredAnimation(
            backgroundImage: "JapaneseTreeWithClouds",
            overlayImage: "CloudSwirls",
            overlayAnimation: .drift(xOffset: 50, yOffset: 20, duration: 15.0)
        )
    )
}
