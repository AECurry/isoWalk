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
import SwiftData
import Observation

@Observable
final class ProgressViewModel {

    // MARK: - State
    var totalWalkCount: Int = 0
    var totalWalkTime: TimeInterval = 0
    var todaySessions: [CompletedSession] = []
    var walksThisMonth: Int = 0
    var longestStreak: Int = 0
    var mostRecentBadgeId: String? = nil
    var isHealthKitEnabled: Bool = false

    // MARK: - Computed Properties
    var badgesEarned: Int { UserDefaults.standard.integer(forKey: "isoWalkBadgesEarnedTotal") }
    var totalWalkCountDisplay: Int { totalWalkCount }

    var formattedTotalTime: String {
        let totalMinutes = Int(totalWalkTime / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(totalMinutes) min"
    }

    var todaySessionCount: Int { todaySessions.count }
    var timelineSessions: [CompletedSession] { Array(todaySessions.prefix(3)) }

    var todayTotalTime: TimeInterval { todaySessions.reduce(0) { $0 + $1.totalDuration } }

    var formattedTodayTime: String {
        let minutes = Int(todayTotalTime / 60)
        return "\(minutes) min"
    }

    // MARK: - Load (Now takes ModelContext)
    func loadData(context: ModelContext) {
        let descriptor = FetchDescriptor<CompletedSession>()
        let all = (try? context.fetch(descriptor)) ?? []
        
        totalWalkCount = all.count
        totalWalkTime = all.reduce(0) { $0 + $1.totalDuration }

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        todaySessions = all
            .filter { calendar.startOfDay(for: $0.startTime) == todayStart }
            .sorted { $0.startTime < $1.startTime }

        walksThisMonth = countWalksThisMonth(from: all)
        longestStreak = calculateLongestStreak(from: all)
        
        mostRecentBadgeId = UserDefaults.standard.string(forKey: "mostRecentBadgeId")
        syncBadgesSilently(context: context)
    }

    private func syncBadgesSilently(context: ModelContext) {
        let badgesVM = BadgesViewModel()
        badgesVM.loadBadges(context: context)
    }

    // MARK: - Helper Logic
    private func countWalksThisMonth(from sessions: [CompletedSession]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return 0 }
        return sessions.filter { $0.startTime >= monthStart }.count
    }

    private func calculateLongestStreak(from sessions: [CompletedSession]) -> Int {
        let calendar = Calendar.current
        let qualifyingDays = Set(
            sessions.filter { $0.totalDuration >= 15 * 60 }
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

