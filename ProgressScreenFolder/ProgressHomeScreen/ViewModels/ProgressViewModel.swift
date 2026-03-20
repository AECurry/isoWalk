//
//  ProgressViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//
//  RESPONSIBILITY: All data logic for the Progress screen.
//  Reads directly from CompletedSession.loadAll() — no repository layer needed.
//  ProgressScreenView is dumb — it only reads from this ViewModel.
//

import SwiftUI
import Observation

@Observable
final class ProgressViewModel {

    // MARK: - State
    var totalWalkCount: Int = 0
    var totalWalkTime: TimeInterval = 0
    var todaySessions: [CompletedSession] = []
    var walksThisMonth: Int = 0
    var longestStreak: Int = 0
    // REMOVED: var badgesEarned: Int = 0 (This was the duplicate!)
    var mostRecentBadgeId: String? = nil
    var isHealthKitEnabled: Bool = false

    // MARK: - Computed Properties
    
    // This connects directly to the count saved by BadgesViewModel
    var badgesEarned: Int {
        UserDefaults.standard.integer(forKey: "isoWalkBadgesEarnedTotal")
    }

    var totalWalkCountDisplay: Int { totalWalkCount }

    var formattedTotalTime: String {
        let totalMinutes = Int(totalWalkTime / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(totalMinutes) min"
    }

    var todaySessionCount: Int { todaySessions.count }

    var timelineSessions: [CompletedSession] {
        Array(todaySessions.prefix(3))
    }

    var todayTotalTime: TimeInterval {
        todaySessions.reduce(0) { $0 + $1.totalDuration }
    }

    var formattedTodayTime: String {
        let minutes = Int(todayTotalTime / 60)
        return "\(minutes) min"
    }

    // MARK: - Load
    func loadData() {
        let all = CompletedSession.loadAll()
        totalWalkCount = all.count
        totalWalkTime = all.reduce(0) { $0 + $1.totalDuration }

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        todaySessions = all
            .filter { calendar.startOfDay(for: $0.startTime) == todayStart }
            .sorted { $0.startTime < $1.startTime }

        walksThisMonth = countWalksThisMonth(from: all)
        longestStreak = calculateLongestStreak(from: all)
        
        // We still load the mostRecentBadgeId from storage
        mostRecentBadgeId = UserDefaults.standard.string(forKey: "mostRecentBadgeId")
        
        // IMPORTANT: We need to trigger the Badge calculation here
        // to make sure the "isoWalkBadgesEarnedTotal" is updated!
        syncBadgesSilently()
    }

    /// This runs the badge checker in the background to ensure the count is current
    private func syncBadgesSilently() {
        let badgesVM = BadgesViewModel()
        badgesVM.loadBadges()
        // This call updates "isoWalkBadgesEarnedTotal" internally
    }

    // MARK: - Helper Logic
    private func countWalksThisMonth(from sessions: [CompletedSession]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)
        ) else { return 0 }
        return sessions.filter { $0.startTime >= monthStart }.count
    }

    private func calculateLongestStreak(from sessions: [CompletedSession]) -> Int {
        let calendar = Calendar.current
        let qualifyingDays = Set(
            sessions
                .filter { $0.totalDuration >= 15 * 60 }
                .map { calendar.startOfDay(for: $0.startTime) }
        )
        guard !qualifyingDays.isEmpty else { return 0 }

        let sorted = qualifyingDays.sorted()
        var best = 1
        var current = 1
        for i in 1..<sorted.count {
            let expected = calendar.date(byAdding: .day, value: 1, to: sorted[i - 1])!
            if sorted[i] == expected {
                current += 1
                best = max(best, current)
            } else {
                current = 1
            }
        }
        return best
    }
}
