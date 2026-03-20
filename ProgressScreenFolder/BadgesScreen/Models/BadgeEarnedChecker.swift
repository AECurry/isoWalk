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
    func check(sessions: [CompletedSession]) -> [BadgeID] {
        BadgeID.allCases.filter { isBadgeEarned($0, sessions: sessions) }
    }

    private func isBadgeEarned(_ id: BadgeID, sessions: [CompletedSession]) -> Bool {
        let cal = Calendar.current
        
        switch id {
        case .firstSteps:
            return !sessions.isEmpty
            
        case .habitWalker:
            let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            return sessions.filter { $0.startTime >= startOfWeek }.count >= 5
            
        case .eveningUnwinder:
            return sessions.contains { cal.component(.hour, from: $0.startTime) >= 20 }
            
        case .morningMover:
            return sessions.contains { cal.component(.hour, from: $0.startTime) < 9 }
            
        case .perfectPace:
            // Assuming totalDuration is in seconds (30 mins * 60)
            return sessions.contains { $0.totalDuration >= 30 * 60 }
            
        case .rhythmFinder:
            return calculateStreak(sessions) >= 7
            
        case .momentumMaker:
            return calculateStreak(sessions) >= 14
        }
    }

    // MARK: - Helper Logic
    private func calculateStreak(_ sessions: [CompletedSession]) -> Int {
        let cal = Calendar.current
        let days = Set(sessions.map { cal.startOfDay(for: $0.startTime) }).sorted(by: >)
        guard !days.isEmpty else { return 0 }
        
        var streak = 0
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        
        // If they haven't walked today or yesterday, streak is broken
        guard days[0] == today || days[0] == yesterday else { return 0 }
        
        var currentDay = days[0]
        streak = 1
        
        for i in 1..<days.count {
            let nextExpectedDay = cal.date(byAdding: .day, value: -1, to: currentDay)!
            if days[i] == nextExpectedDay {
                streak += 1
                currentDay = days[i]
            } else {
                break
            }
        }
        return streak
    }
}
