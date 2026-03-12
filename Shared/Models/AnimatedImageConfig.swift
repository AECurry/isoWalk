//
//  AnimatedImageConfig.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
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
// MARK: - CONFIG MODEL
// ==========================================

struct AnimatedImageConfig: Identifiable {

    let id: String
    let name: String
    let imageName: String
    let description: String
    let logoImageName: String

    let defaultRotationSpeed: Double
    let defaultMinScale: Double
    let defaultMaxScale: Double
    let defaultScaleSpeed: Double

    var userRotationSpeedKey:   String { "\(id)_rotationSpeed" }
    var userMinScaleKey:        String { "\(id)_minScale" }
    var userMaxScaleKey:        String { "\(id)_maxScale" }
    var userScaleSpeedKey:      String { "\(id)_scaleSpeed" }
    var rotationEnabledKey:     String { "\(id)_rotationEnabled" }
    var scaleEnabledKey:        String { "\(id)_scaleEnabled" }

    var rotationSpeed: Double {
        let v = UserDefaults.standard.double(forKey: userRotationSpeedKey)
        return v > 0 ? v : defaultRotationSpeed
    }
    var minScale: Double {
        let v = UserDefaults.standard.double(forKey: userMinScaleKey)
        return v > 0 ? v : defaultMinScale
    }
    var maxScale: Double {
        let v = UserDefaults.standard.double(forKey: userMaxScaleKey)
        return v > 0 ? v : defaultMaxScale
    }
    var scaleSpeed: Double {
        let v = UserDefaults.standard.double(forKey: userScaleSpeedKey)
        return v > 0 ? v : defaultScaleSpeed
    }
    var isRotationEnabled: Bool {
        guard UserDefaults.standard.object(forKey: rotationEnabledKey) != nil else { return true }
        return UserDefaults.standard.bool(forKey: rotationEnabledKey)
    }
    var isScaleEnabled: Bool {
        guard UserDefaults.standard.object(forKey: scaleEnabledKey) != nil else { return true }
        return UserDefaults.standard.bool(forKey: scaleEnabledKey)
    }

    init(
        id: String,
        name: String,
        imageName: String,
        description: String,
        logoImageName: String? = nil,
        defaultRotationSpeed: Double = 20.0,
        defaultMinScale: Double = 0.94,
        defaultMaxScale: Double = 1.08,
        defaultScaleSpeed: Double = 4.0
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.description = description
        self.logoImageName = logoImageName ?? imageName
        self.defaultRotationSpeed = defaultRotationSpeed
        self.defaultMinScale = defaultMinScale
        self.defaultMaxScale = defaultMaxScale
        self.defaultScaleSpeed = defaultScaleSpeed
    }

    func saveRotationSpeed(_ speed: Double)     { UserDefaults.standard.set(speed,   forKey: userRotationSpeedKey) }
    func saveMinScale(_ scale: Double)          { UserDefaults.standard.set(scale,   forKey: userMinScaleKey) }
    func saveMaxScale(_ scale: Double)          { UserDefaults.standard.set(scale,   forKey: userMaxScaleKey) }
    func saveScaleSpeed(_ speed: Double)        { UserDefaults.standard.set(speed,   forKey: userScaleSpeedKey) }
    func saveRotationEnabled(_ enabled: Bool)   { UserDefaults.standard.set(enabled, forKey: rotationEnabledKey) }
    func saveScaleEnabled(_ enabled: Bool)      { UserDefaults.standard.set(enabled, forKey: scaleEnabledKey) }

    func resetToDefaults() {
        [userRotationSpeedKey, userMinScaleKey, userMaxScaleKey,
         userScaleSpeedKey, rotationEnabledKey, scaleEnabledKey]
            .forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
}

// ==========================================
// MARK: - LIBRARY
// ADD A NEW THEME HERE — nothing else needs to change.
// ==========================================

struct AnimatedImageLibrary {

    static let availableImages: [AnimatedImageConfig] = [

        // ── Theme 1: Japanese Koi ──────────────────────────────────────
        AnimatedImageConfig(
            id: "koi",
            name: "Japanese Koi",
            imageName: "JapaneseKoi",
            description: "Two koi swimming in harmony",
            logoImageName: "JapaneseKoi",
            defaultRotationSpeed: 88.0,
            defaultMinScale: 1.0,
            defaultMaxScale: 1.08,   // reduced from 1.32 — subtle pulse
            defaultScaleSpeed: 8.0
        ),

        // ── ADD NEW THEMES BELOW THIS LINE ────────────────────────────
        // Example:
        // AnimatedImageConfig(
        //     id: "bonsai",
        //     name: "Japanese Tree with Clouds",
        //     imageName: "BonsaiTree",
        //     description: "A peaceful bonsai under cloudy skies",
        //     logoImageName: "BonsaiTree",
        //     defaultRotationSpeed: 0,
        //     defaultMinScale: 0.96,
        //     defaultMaxScale: 1.08,
        //     defaultScaleSpeed: 6.0
        // ),
    ]

    static func getImage(byId id: String) -> AnimatedImageConfig? {
        availableImages.first { $0.id == id }
    }

    static func getCurrentImage() -> AnimatedImageConfig {
        let selectedId = UserDefaults.standard.string(forKey: "selectedImageId") ?? "koi"
        return getImage(byId: selectedId) ?? availableImages[0]
    }

    static func setCurrentImage(id: String) {
        UserDefaults.standard.set(id, forKey: "selectedImageId")
    }

    static func resetAllImagesToDefaults() {
        availableImages.forEach { $0.resetToDefaults() }
    }
}

