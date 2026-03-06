//
//  BadgesViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  RESPONSIBILITY: UI state and persistence only.
//  Delegates all earn-condition logic to BadgeEarnedChecker.
//  BadgesScreenView is dumb — it only reads from this ViewModel.
//

import SwiftUI
import Observation

@Observable
final class BadgesViewModel {

    // MARK: - UI State
    var badges: [Badge] = []
    var newlyUnlockedBadge: Badge? = nil
    var showRevealAnimation: Bool = false
    var selectedBadge: Badge? = nil
    var showDetailSheet: Bool = false

    // MARK: - Private
    private let checker = BadgeEarnedChecker()
    private let persistenceKey = "earnedBadgeRecords"

    // MARK: - Computed
    var earnedCount: Int {
        badges.filter { $0.isUnlocked }.count
    }

    var mostRecentBadge: Badge? {
        badges
            .filter { $0.isUnlocked }
            .sorted {
                ($0.unlockedDate ?? .distantPast) > ($1.unlockedDate ?? .distantPast)
            }
            .first
    }

    // MARK: - Load
    func loadBadges() {
        let sessions = CompletedSession.loadAll()
        let earned = loadEarnedRecords()
        let earnedIds = Set(earned.map { $0.badgeId })

        // Build badge list in fixed order 1-38
        badges = BadgeID.allCases.map { badgeId in
            let record = earned.first { $0.badgeId == badgeId.rawValue }
            return Badge(id: badgeId, unlockedDate: record?.earnedDate)
        }

        checkForNewBadges(sessions: sessions, alreadyEarned: earnedIds)
    }

    // MARK: - Badge Tap
    func didTapBadge(_ badge: Badge) {
        selectedBadge = badge
        showDetailSheet = true
    }

    // MARK: - Reveal
    func didShowReveal() {
        showRevealAnimation = false
        newlyUnlockedBadge = nil
    }

    // MARK: - Check for New Badges
    private func checkForNewBadges(
        sessions: [CompletedSession],
        alreadyEarned: Set<String>
    ) {
        let hasSecondWind = UserDefaults.standard.bool(forKey: "hasSecondWindBadge")
        let hasPauseFree = UserDefaults.standard.bool(forKey: "hasCompletedPauseFreeSession")

        // Delegate all logic to BadgeEarnedChecker
        let nowEarned = checker.check(
            sessions: sessions,
            hasSecondWind: hasSecondWind,
            hasPauseFreeSession: hasPauseFree
        )

        let newlyEarned = nowEarned
            .filter { !alreadyEarned.contains($0.rawValue) }
            .map { EarnedBadgeRecord(badgeId: $0.rawValue, earnedDate: Date()) }

        guard !newlyEarned.isEmpty else { return }

        // Persist
        var all = loadEarnedRecords()
        all.append(contentsOf: newlyEarned)
        saveEarnedRecords(all)

        // Rebuild badge list with new unlock dates
        badges = BadgeID.allCases.map { badgeId in
            let record = all.first { $0.badgeId == badgeId.rawValue }
            return Badge(id: badgeId, unlockedDate: record?.earnedDate)
        }

        // Trigger reveal for most recently earned badge
        if let latest = newlyEarned.last,
           let badgeId = BadgeID(rawValue: latest.badgeId) {
            newlyUnlockedBadge = Badge(id: badgeId, unlockedDate: latest.earnedDate)
            showRevealAnimation = true
        }

        // Update ProgressHeader badge state
        updateProgressHeaderState(from: all)
    }

    // MARK: - Update Progress Header
    private func updateProgressHeaderState(from records: [EarnedBadgeRecord]) {
        UserDefaults.standard.set(records.count, forKey: "badgesEarned")
        if let latest = records.sorted(by: { $0.earnedDate > $1.earnedDate }).first {
            UserDefaults.standard.set(latest.badgeId, forKey: "mostRecentBadgeId")
        }
    }

    // MARK: - Persistence
    private func loadEarnedRecords() -> [EarnedBadgeRecord] {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey)
        else { return [] }
        return (try? JSONDecoder().decode([EarnedBadgeRecord].self, from: data)) ?? []
    }

    private func saveEarnedRecords(_ records: [EarnedBadgeRecord]) {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: persistenceKey)
        }
    }
}
