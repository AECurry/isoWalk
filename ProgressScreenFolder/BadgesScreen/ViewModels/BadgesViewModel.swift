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
    // The Progress card will eventually read directly from this.
    var earnedCount: Int {
        badges.filter { $0.isUnlocked }.count
    }

    var mostRecentBadge: Badge? {
        badges
            .filter { $0.isUnlocked }
            .sorted { ($0.unlockedDate ?? .distantPast) > ($1.unlockedDate ?? .distantPast) }
            .first
    }

    // MARK: - Public API
    func loadBadges() {
        let sessions = CompletedSession.loadAll()
        let earnedRecords = loadEarnedRecords()
        let alreadyEarnedIds = Set(earnedRecords.map { $0.badgeId })

        // 1. Build initial list
        badges = BadgeID.allCases.map { badgeId in
            let record = earnedRecords.first { $0.badgeId == badgeId.rawValue }
            return Badge(id: badgeId, unlockedDate: record?.earnedDate)
        }

        // 2. RUN DYNAMIC SYNC against session history
        syncWithSessionHistory(sessions: sessions, alreadyEarned: alreadyEarnedIds, earnedRecords: earnedRecords)
    }

    // MARK: - User Interactions
    func handleBadgeTap(_ badge: Badge) {
        selectedBadge = badge
        showDetailSheet = true
    }

    func dismissDetailSheet() {
        showDetailSheet = false
        selectedBadge = nil
    }

    func dismissReveal() {
        showRevealAnimation = false
        newlyUnlockedBadge = nil
    }

    // MARK: - Dynamic Logic & Sync
    private func syncWithSessionHistory(
        sessions: [CompletedSession],
        alreadyEarned: Set<String>,
        earnedRecords: [EarnedBadgeRecord]
    ) {
        // Run the dynamic logic checker
        let nowEarnedFromHistory = checker.check(sessions: sessions)

        let newlyEarnedInThisSession = nowEarnedFromHistory
            .filter { !alreadyEarned.contains($0.rawValue) }
            .map { EarnedBadgeRecord(badgeId: $0.rawValue, earnedDate: Date()) }

        guard !newlyEarnedInThisSession.isEmpty else {
            // Even if no new badges found, we still need to ensure the count is correct.
            saveEarnedCountToUserDefaults(earnedRecords.count)
            return
        }

        // --- NEW BADGES DETECTED ---
        var allRecords = earnedRecords
        allRecords.append(contentsOf: newlyEarnedInThisSession)
        
        // Persist the full record set
        saveEarnedRecords(allRecords)
        
        // UNIFY TRUTH: Save the true count to UserDefaults for the Progress screen
        saveEarnedCountToUserDefaults(allRecords.count)

        // Update local badges array so UI refreshes immediately
        badges = BadgeID.allCases.map { badgeId in
            let record = allRecords.first { $0.badgeId == badgeId.rawValue }
            return Badge(id: badgeId, unlockedDate: record?.earnedDate)
        }

        // Trigger reveal animation for the first newly earned badge
        if let firstNew = newlyEarnedInThisSession.first,
           let matchedBadge = badges.first(where: { $0.id.rawValue == firstNew.badgeId }) {
            
            // Save this as the most recent badge id for the progress screen icon
            UserDefaults.standard.set(matchedBadge.id.rawValue, forKey: "mostRecentBadgeId")
            
            // Show the full screen reveal
            newlyUnlockedBadge = matchedBadge
            showRevealAnimation = true
        }
    }

    private func saveEarnedCountToUserDefaults(_ count: Int) {
        // This is the number that the Progress card reads.
        UserDefaults.standard.set(count, forKey: "isoWalkBadgesEarnedTotal")
    }

    // MARK: - Persistence Helpers
    private func loadEarnedRecords() -> [EarnedBadgeRecord] {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey) else { return [] }
        do {
            return try JSONDecoder().decode([EarnedBadgeRecord].self, from: data)
        } catch {
            print("Failed to decode badge records: \(error)")
            return []
        }
    }

    private func saveEarnedRecords(_ records: [EarnedBadgeRecord]) {
        do {
            let data = try JSONEncoder().encode(records)
            UserDefaults.standard.set(data, forKey: persistenceKey)
        } catch {
            print("Failed to encode badge records: \(error)")
        }
    }
}
