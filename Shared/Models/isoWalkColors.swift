//
//  isoWalkColors.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI

struct isoWalkColors {

    // Brand colors
    static let balticBlue    = Color(hex: "1665A1")
    static let deepSpaceBlue = Color(hex: "08263D")

    // Text and Gray Scale
    static let jetBlack   = Color(hex: "082830")
    static let white      = Color(hex: "FFFEFE")
    static let silverMist = Color(hex: "E0E0E0")
    static let slateGray  = Color(hex: "707070")

    // Background colors
    static let parchment = Color(hex: "F5F0E8")
    
    // Stop, Play, Pause colors
    static let brandy = Color(hex: "912216")
    static let forestGreen = Color(hex: "238732")

    // MARK: - Gradient (top: balticBlue → bottom: deepSpaceBlue)
    static let gradientBlue = LinearGradient(
        colors: [balticBlue, deepSpaceBlue],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Adaptive Colors
    static var adaptiveBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(jetBlack) : UIColor.white
        })
    }

    static var adaptiveText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        })
    }
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

