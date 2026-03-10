//
//  BadgeEarnedChecker.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//
//  PURE LOGIC — no UI, no @Observable, no SwiftUI.
//  Single responsibility: given a list of sessions, return which badges
//  have been earned. BadgesViewModel calls this — nothing else does.
//

import Foundation

struct BadgeEarnedChecker {

    // MARK: - Public API
    func check(
        sessions: [CompletedSession],
        hasSecondWind: Bool,
        hasPauseFreeSession: Bool
    ) -> [BadgeID] {
        BadgeID.allCases.filter {
            isBadgeEarned(
                $0,
                sessions: sessions,
                hasSecondWind: hasSecondWind,
                hasPauseFreeSession: hasPauseFreeSession
            )
        }
    }

    // MARK: - Individual Conditions
    private func isBadgeEarned(
        _ id: BadgeID,
        sessions: [CompletedSession],
        hasSecondWind: Bool,
        hasPauseFreeSession: Bool
    ) -> Bool {
        let cal = Calendar.current
        switch id {

        // MARK: Streaks
        case .rhythmFinder:     return currentStreak(sessions) >= 7
        case .momentumMaker:    return currentStreak(sessions) >= 14
        case .habitWalker:      return currentStreak(sessions) >= 21
        case .perfectPace:      return currentStreak(sessions) >= 31
        case .lifestyleWalker:  return currentStreak(sessions) >= 90
        case .paceLegend:       return currentStreak(sessions) >= 120

        // MARK: Session Milestones
        case .firstSteps:       return sessions.count >= 1
        case .waypoint:         return sessions.count >= 25
        case .theGoldenWalker:  return sessions.count >= 50
        case .the200Club:       return sessions.count >= 200
        case .theLongRoad:      return sessions.count >= 365

        // MARK: Time of Day
        case .earlyRiser:
            return sessions.filter {
                cal.component(.hour, from: $0.startTime) < 7
            }.count >= 10

        case .morningMover:
            return sessions.filter {
                cal.component(.hour, from: $0.startTime) < 9
            }.count >= 10

        case .middayMover:
            return sessions.filter {
                let h = cal.component(.hour, from: $0.startTime)
                return h >= 11 && h < 13
            }.count >= 10

        case .eveningUnwinder:
            return sessions.filter {
                cal.component(.hour, from: $0.startTime) >= 18
            }.count >= 10

        case .goldenHour:
            return sessions.filter {
                let h = cal.component(.hour, from: $0.startTime)
                return h >= 17 && h < 19
            }.count >= 10

        // MARK: Full Session / Consistency
        case .isoAthlete:       return fullSessionStreak(sessions) >= 60
        case .masterOfMomentum: return fullSessionStreak(sessions) >= 100
        case .ironMonth:        return hasCompletedFullMonth(sessions)
        case .yearRounder:      return hasCompletedEveryMonthForYear(sessions)

        // MARK: Interval Badges
        // Interval = .brisk pace, 33+ minutes
        case .intervalBeginner:  return intervalSessionCount(sessions) >= 7
        case .intervalModerate:  return intervalSessionCount(sessions) >= 14
        case .intervalAdvanced:  return intervalSessionCount(sessions) >= 21
        case .intervalMaster:    return intervalSessionCount(sessions) >= 31
        case .intervalChampion:  return intervalSessionCount(sessions) >= 100

        // MARK: Personal Achievement
        case .unbroken:
            return hasPauseFreeSession

        case .weekendWarrior:
            let weekendDays = Set(sessions
                .filter {
                    let w = cal.component(.weekday, from: $0.startTime)
                    return w == 1 || w == 7
                }
                .map { cal.startOfDay(for: $0.startTime) })
            return weekendDays.count >= 2

        case .doubleDown:
            return hasDoubleSessionDay(sessions)

        case .tripleThreat:
            return hasTripleSessionDay(sessions)

        case .trailblazer:
            let weekdays = Set(sessions.map {
                cal.component(.weekday, from: $0.startTime)
            })
            return weekdays.count >= 7

        // Slowest pace = .leisurely
        case .justBreathe:
            return sessions.contains { $0.pace == .leisurely }

        case .mindAndBody:
            return sessions.filter { $0.pace == .leisurely }.count >= 10

        // MARK: Journey
        case .seasonedTraveler:
            let months = Set(sessions.map {
                cal.dateComponents([.year, .month], from: $0.startTime)
            })
            return months.count >= 3

        case .secondWind:
            return hasSecondWind

        // MARK: HealthKit
        case .mileMarker:
            return false // wired when HealthKit is implemented

        // MARK: Time Totals
        case .minutes100Club:
            return sessions.reduce(0) { $0 + $1.totalDuration } >= 100 * 60

        case .hours60Club:
            return sessions.reduce(0) { $0 + $1.totalDuration } >= 60 * 3_600

        case .hours120Club:
            return sessions.reduce(0) { $0 + $1.totalDuration } >= 120 * 3_600
        }
    }

    // MARK: - Streak Helpers
    private func currentStreak(_ sessions: [CompletedSession]) -> Int {
        let cal = Calendar.current
        let days = Set(sessions.map {
            cal.startOfDay(for: $0.startTime)
        }).sorted(by: >)
        guard !days.isEmpty else { return 0 }
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        guard days[0] == today || days[0] == yesterday else { return 0 }
        var streak = 1
        var checking = days[0]
        for day in days.dropFirst() {
            let expected = cal.date(byAdding: .day, value: -1, to: checking)!
            if day == expected { streak += 1; checking = day } else { break }
        }
        return streak
    }

    private func fullSessionStreak(_ sessions: [CompletedSession]) -> Int {
        // Full session = totalDuration matches chosen duration within 5 seconds
        let full = sessions.filter {
            let expected = TimeInterval($0.duration.minutes * 60)
            return abs($0.totalDuration - expected) < 5
        }
        return currentStreak(full)
    }

    // MARK: - Interval Count
    // Interval sessions = .brisk pace + 33 minutes or more
    private func intervalSessionCount(_ sessions: [CompletedSession]) -> Int {
        sessions.filter {
            $0.pace == .brisk && $0.totalDuration >= 33 * 60
        }.count
    }

    // MARK: - Calendar Helpers
    private func hasCompletedFullMonth(_ sessions: [CompletedSession]) -> Bool {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: sessions) {
            cal.dateComponents([.year, .month], from: $0.startTime)
        }
        for (components, _) in grouped {
            guard let monthStart = cal.date(from: components),
                  let range = cal.range(of: .day, in: .month, for: monthStart)
            else { continue }
            let uniqueDays = Set(sessions
                .filter {
                    cal.dateComponents([.year, .month], from: $0.startTime) == components
                }
                .map { cal.component(.day, from: $0.startTime) }
            ).count
            if uniqueDays >= range.count { return true }
        }
        return false
    }

    private func hasCompletedEveryMonthForYear(_ sessions: [CompletedSession]) -> Bool {
        let cal = Calendar.current
        let months = Set(sessions.map {
            cal.dateComponents([.year, .month], from: $0.startTime)
        })
        guard months.count >= 12 else { return false }
        let years = Set(months.compactMap { $0.year })
        for year in years {
            let monthsInYear = Set(
                months.filter { $0.year == year }.compactMap { $0.month }
            )
            if monthsInYear.count >= 12 { return true }
        }
        return false
    }

    private func hasDoubleSessionDay(_ sessions: [CompletedSession]) -> Bool {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: sessions) {
            cal.startOfDay(for: $0.startTime)
        }
        return grouped.values.contains { $0.count >= 2 }
    }

    private func hasTripleSessionDay(_ sessions: [CompletedSession]) -> Bool {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: sessions) {
            cal.startOfDay(for: $0.startTime)
        }
        return grouped.values.contains { $0.count >= 3 }
    }
}

