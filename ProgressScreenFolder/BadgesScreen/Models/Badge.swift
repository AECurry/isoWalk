//
//  Badge.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//
//  Defines all 38 badges as a typed enum.
//  Badge struct carries display info, unlock state, and theme-aware image name.
//  No business logic lives here — BadgesViewModel owns all unlock decisions.
//

import Foundation
import SwiftData

// MARK: - Badge ID
enum BadgeID: String, CaseIterable, Codable {
    case firstSteps
    case habitWalker
    case eveningUnwinder
    case morningMover
    case perfectPace
    case rhythmFinder
    case momentumMaker
    case lifestyleWalker
    case paceLegend
    case earlyRiser
    case middayMover
}

extension BadgeID {
    var displayName: String {
        switch self {
        case .firstSteps:       return "First Steps"
        case .habitWalker:      return "Habit Walker"
        case .eveningUnwinder:  return "Evening UnWinder"
        case .morningMover:     return "Morning Mover"
        case .perfectPace:      return "Perfect Pace"
        case .rhythmFinder:     return "Rhythm Finder"
        case .momentumMaker:    return "Momentum Maker"
        case .lifestyleWalker:  return "Lifestyle Walker"
        case .paceLegend:       return "Pace Legend"
        case .earlyRiser:        return "Early Riser"
        case .middayMover:        return "Midday Mover"

        }
    }

    var requirement: String {
        switch self {
        case .firstSteps:       return "Complete your very first session."
        case .habitWalker:      return "Complete 5 sessions in a single week."
        case .eveningUnwinder:  return "Complete a session after 6:00 PM."
        case .morningMover:     return "Complete a session before 9:00 AM."
        case .perfectPace:      return "Complete a session of at least 30 minutes."
        case .rhythmFinder:     return "Maintain a 7-day walking streak."
        case .momentumMaker:    return "Maintain a 14-day walking streak."
        case .lifestyleWalker:   return "Complete a 90 day consistant walking streak."
        case .paceLegend:       return "Complete a 120 day consistant walking streak."
        case .earlyRiser:        return "Complete 10 walking sessions before 8:00 AM."
        case .middayMover:        return "Complete 10 walking sessions between 11:00 AM - 1:00 PM"
        }
    }

    private var exactAssetFileName: String {
        switch self {
        case .firstSteps:       return "FirstSteps"
        case .habitWalker:      return "HabitWalker"
        case .eveningUnwinder:  return "EveningUnWinder"
        case .morningMover:     return "MorningMover"
        case .perfectPace:      return "PerfectPace"
        case .rhythmFinder:     return "RhythmFinder"
        case .momentumMaker:    return "MomentumMaker"
        case .lifestyleWalker:  return "LifestyleWalker"
        case .paceLegend:       return "PaceLegend"
        case .earlyRiser:        return "Early Riser"
        case .middayMover:        return "Midday Mover"
        }
    }

    func imageName(themeId: String) -> String {
        let folder = badgeFolder(for: themeId)
        return "\(folder)/\(exactAssetFileName)"
    }

    private func badgeFolder(for themeId: String) -> String {
        switch themeId {
        case "JapaneseKoi", "JapaneseTree":
            return "JapaneseBadges"
        default:
            return "JapaneseBadges"
        }
    }
}

// MARK: - Badge Struct (UI Display Model)
struct Badge: Identifiable {
    let id: BadgeID
    let unlockedDate: Date?
    var isUnlocked: Bool { unlockedDate != nil }

    var formattedUnlockDate: String? {
        guard let date = unlockedDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

