//
//  IsoWalkThemes.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  SOURCE OF TRUTH for all theme data.
//  To add a new theme: add ONE entry to AnimatedImageLibrary.availableImages
//  in AnimatedImageConfig.swift. Nothing else needs to change.
//
//  CONTAINS:
//  - ThemeAnimationType    → the animation styles a theme can have
//  - IsoWalkTheme          → model for ONE theme (singular is correct Swift convention)
//  - IsoWalkThemes         → the collection/catalog of ALL themes + helper methods
//

import SwiftUI

// ==========================================
// MARK: - ANIMATION TYPE
// ==========================================

enum ThemeAnimationType {
    case rotation(speed: Double)
    case pulse(minScale: Double, maxScale: Double, speed: Double)
    case rotatingPulse(rotSpeed: Double, minScale: Double, maxScale: Double, pulseSpeed: Double)
    case none
}

// ==========================================
// MARK: - THEME MODEL (one theme)
// ==========================================

struct IsoWalkTheme: Identifiable {
    let id: String
    let displayName: String
    let mainImageName: String
    let backgroundImageName: String?
    let backgroundColor: Color
    let animationType: ThemeAnimationType

    // Built dynamically from a config — no manual wiring needed
    init(from config: AnimatedImageConfig) {
        self.id = config.id
        self.displayName = config.name
        self.mainImageName = config.imageName
        self.backgroundImageName = "GoldenTextureBackground"
        self.backgroundColor = isoWalkColors.parchment

        if config.isRotationEnabled && config.isScaleEnabled {
            self.animationType = .rotatingPulse(
                rotSpeed: config.rotationSpeed,
                minScale: config.minScale,
                maxScale: config.maxScale,
                pulseSpeed: config.scaleSpeed
            )
        } else if config.isRotationEnabled {
            self.animationType = .rotation(speed: config.rotationSpeed)
        } else if config.isScaleEnabled {
            self.animationType = .pulse(
                minScale: config.minScale,
                maxScale: config.maxScale,
                speed: config.scaleSpeed
            )
        } else {
            self.animationType = .none
        }
    }
}

// ==========================================
// MARK: - ISOWALKSTHEMES (the full catalog)
// Derives all themes dynamically from AnimatedImageLibrary.
// Add a new theme there — this catalog updates automatically.
//
// USAGE ANYWHERE IN THE APP:
//   IsoWalkThemes.all               → [IsoWalkTheme]
//   IsoWalkThemes.current(selectedId:) → IsoWalkTheme
//   IsoWalkThemes.selectedThemeKey  → UserDefaults key String
// ==========================================

struct IsoWalkThemes {

    // All available themes, built from AnimatedImageLibrary
    static var all: [IsoWalkTheme] {
        AnimatedImageLibrary.availableImages.map { IsoWalkTheme(from: $0) }
    }

    // The currently selected theme
    static func current(selectedId: String) -> IsoWalkTheme {
        all.first { $0.id == selectedId } ?? all[0]
    }

    // UserDefaults key — use this everywhere so it never drifts out of sync
    static let selectedThemeKey = "selectedThemeId"
    static let defaultThemeId   = "koi"
}

