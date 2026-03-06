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

// MARK: - Badge ID
// Single source of truth for all 38 badges.
// Add new badges here and nowhere else.
enum BadgeID: String, CaseIterable, Codable {
    // Streak
    case rhythmFinder
    case momentumMaker
    case habitWalker
    case perfectPace
    case lifestyleWalker
    case paceLegend

    // Session milestones
    case firstSteps
    case waypoint
    case theGoldenWalker
    case the200Club
    case theLongRoad

    // Time of day
    case earlyRiser
    case morningMover
    case middayMover
    case eveningUnwinder
    case goldenHour

    // Full session / consistency
    case isoAthlete
    case masterOfMomentum
    case ironMonth
    case yearRounder

    // Interval
    case intervalBeginner
    case intervalModerate
    case intervalAdvanced
    case intervalMaster
    case intervalChampion

    // Personal achievement
    case unbroken
    case weekendWarrior
    case doubleDown
    case tripleThreat
    case trailblazer
    case justBreathe
    case mindAndBody

    // Journey
    case seasonedTraveler
    case secondWind

    // HealthKit
    case mileMarker

    // Time totals
    case minutes100Club
    case hours60Club
    case hours120Club
}

// MARK: - Badge Display Info
extension BadgeID {
    var displayName: String {
        switch self {
        case .rhythmFinder:       return "Rhythm Finder"
        case .momentumMaker:      return "Momentum Maker"
        case .habitWalker:        return "Habit Walker"
        case .perfectPace:        return "Perfect Pace"
        case .lifestyleWalker:    return "Lifestyle Walker"
        case .paceLegend:         return "Pace Legend"
        case .firstSteps:         return "First Steps"
        case .waypoint:           return "Waypoint"
        case .theGoldenWalker:    return "The Golden Walker"
        case .the200Club:         return "The 200 Club"
        case .theLongRoad:        return "The Long Road"
        case .earlyRiser:         return "Early Riser"
        case .morningMover:       return "Morning Mover"
        case .middayMover:        return "Midday Mover"
        case .eveningUnwinder:    return "Evening Unwinder"
        case .goldenHour:         return "Golden Hour"
        case .isoAthlete:         return "Iso Athlete"
        case .masterOfMomentum:   return "Master of Momentum"
        case .ironMonth:          return "Iron Month"
        case .yearRounder:        return "Year Rounder"
        case .intervalBeginner:   return "Interval Beginner Walker"
        case .intervalModerate:   return "Interval Moderate Walker"
        case .intervalAdvanced:   return "Interval Advanced Walker"
        case .intervalMaster:     return "Interval Master Walker"
        case .intervalChampion:   return "Interval Champion Walker"
        case .unbroken:           return "Unbroken"
        case .weekendWarrior:     return "Weekend Warrior"
        case .doubleDown:         return "Double Down"
        case .tripleThreat:       return "Triple Threat"
        case .trailblazer:        return "Trailblazer"
        case .justBreathe:        return "Just Breathe"
        case .mindAndBody:        return "Mind and Body"
        case .seasonedTraveler:   return "Seasoned Traveler"
        case .secondWind:         return "Second Wind"
        case .mileMarker:         return "Mile Marker"
        case .minutes100Club:     return "100 Minutes Club"
        case .hours60Club:        return "60 Minutes Club"
        case .hours120Club:       return "120 Minutes Club"
        }
    }

    var requirement: String {
        switch self {
        case .rhythmFinder:       return "Complete a 7-day consistent streak."
        case .momentumMaker:      return "Complete a 14-day consistent streak."
        case .habitWalker:        return "Complete a 21-day consistent streak."
        case .perfectPace:        return "Complete a 31-day consistent streak."
        case .lifestyleWalker:    return "Complete a 90-day consistent streak."
        case .paceLegend:         return "Complete a 120-day consistent streak."
        case .firstSteps:         return "Complete your very first session."
        case .waypoint:           return "Complete 25 total sessions."
        case .theGoldenWalker:    return "Complete 50 total sessions."
        case .the200Club:         return "Complete 200 total sessions."
        case .theLongRoad:        return "Complete 365 total sessions."
        case .earlyRiser:         return "Complete 10 sessions before 7am."
        case .morningMover:       return "Complete 10 sessions before 9am."
        case .middayMover:        return "Complete 10 sessions between 11am and 1pm."
        case .eveningUnwinder:    return "Complete 10 sessions after 6pm."
        case .goldenHour:         return "Complete 10 sessions between 5pm and 7pm."
        case .isoAthlete:         return "Complete a 60-day streak of full walking sessions."
        case .masterOfMomentum:   return "Complete a 100-day streak of full walking sessions."
        case .ironMonth:          return "Complete every day of a full calendar month."
        case .yearRounder:        return "Complete at least one session every month for a full year."
        case .intervalBeginner:   return "Complete 7 interval sessions of 33+ minutes using the 3-to-3 normal to brisk pace."
        case .intervalModerate:   return "Complete 14 interval sessions of 33+ minutes using the 3-to-3 normal to brisk pace."
        case .intervalAdvanced:   return "Complete 21 interval sessions of 33+ minutes using the 3-to-3 normal to brisk pace."
        case .intervalMaster:     return "Complete 31 interval sessions of 33+ minutes using the 3-to-3 normal to brisk pace."
        case .intervalChampion:   return "Complete 100 interval sessions of 33+ minutes using the 3-to-3 normal to brisk pace."
        case .unbroken:           return "Complete your first session without pausing."
        case .weekendWarrior:     return "Complete your first two sessions over a weekend."
        case .doubleDown:         return "Complete two sessions in one day for the first time."
        case .tripleThreat:       return "Complete three sessions in one day."
        case .trailblazer:        return "Complete sessions on all 7 days of the week."
        case .justBreathe:        return "Complete one session at the slowest pace setting."
        case .mindAndBody:        return "Complete 10 sessions at the slowest pace setting."
        case .seasonedTraveler:   return "Complete a walk in three different months."
        case .secondWind:         return "Complete a session after a 7+ day gap (first time only)."
        case .mileMarker:         return "Complete your first 10 miles. Requires HealthKit."
        case .minutes100Club:     return "Complete 100 total minutes of walking."
        case .hours60Club:        return "Complete 60 total hours of walking."
        case .hours120Club:       return "Complete 120 total hours of walking."
        }
    }

    // Theme-aware image name for unlocked badge.
    // Returns asset name like "FirstSteps_Golden", "FirstSteps_Ocean" etc.
    // Falls back to locked placeholder if asset not found.
    func imageName(themeId: String) -> String {
        return "\(self.rawValue)_\(themeId)"
    }

    // Locked placeholder is also theme-aware.
    static func lockedImageName(themeId: String) -> String {
        return "LockedBadge_\(themeId)"
    }
}

// MARK: - Badge
// Immutable value type representing a single badge and its current state.
struct Badge: Identifiable {
    let id: BadgeID
    let unlockedDate: Date?

    var isUnlocked: Bool { unlockedDate != nil }

    var formattedUnlockDate: String? {
        guard let date = unlockedDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Earned Badge Record (persisted)
struct EarnedBadgeRecord: Codable {
    let badgeId: String
    let earnedDate: Date
}
