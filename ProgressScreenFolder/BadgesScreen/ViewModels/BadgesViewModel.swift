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
import SwiftData
import Observation

@Observable
final class BadgesViewModel {

    // MARK: - UI State
    var badges: [Badge] = []
    var newlyUnlockedBadge: Badge? = nil
    var showRevealAnimation: Bool = false
    var selectedBadge: Badge? = nil
    var showDetailSheet: Bool = false

    private let checker = BadgeEarnedChecker()
    
    var earnedCount: Int {
        badges.filter { $0.isUnlocked }.count
    }
    
    var mostRecentBadge: Badge? {
        guard let idString = UserDefaults.standard.string(forKey: "mostRecentBadgeId"),
              let badgeId = BadgeID(rawValue: idString) else { return nil }
        return badges.first { $0.id == badgeId }
    }

    // MARK: - Public API
    func loadBadges(context: ModelContext) {
        let sessionDescriptor = FetchDescriptor<CompletedSession>()
        let badgeDescriptor = FetchDescriptor<EarnedBadgeRecord>()
            
        let sessions = (try? context.fetch(sessionDescriptor)) ?? []
        let earnedRecords = (try? context.fetch(badgeDescriptor)) ?? []
            
        syncWithSessionHistory(context: context, sessions: sessions, earnedRecords: earnedRecords)
    }

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
        context: ModelContext,
        sessions: [CompletedSession],
        earnedRecords: [EarnedBadgeRecord]
    ) {
        let nowEarnedFromHistory = checker.check(sessions: sessions)
        let newlyEarnedIds = Set(nowEarnedFromHistory.map { $0.rawValue })

        for record in earnedRecords {
            if !newlyEarnedIds.contains(record.badgeId) {
                context.delete(record)
            }
        }

        let existingRecordIds = Set(earnedRecords.map { $0.badgeId })
        var newlyEarnedInThisSession: [EarnedBadgeRecord] = []
        
        for badgeId in nowEarnedFromHistory {
            if !existingRecordIds.contains(badgeId.rawValue) {
                let newRecord = EarnedBadgeRecord(badgeId: badgeId.rawValue, earnedDate: Date())
                context.insert(newRecord)
                newlyEarnedInThisSession.append(newRecord)
            }
        }
        
        try? context.save()

        let finalRecords = (try? context.fetch(FetchDescriptor<EarnedBadgeRecord>())) ?? []
        
        badges = BadgeID.allCases.map { badgeId in
            let record = finalRecords.first { $0.badgeId == badgeId.rawValue }
            return Badge(id: badgeId, unlockedDate: record?.earnedDate)
        }
        
        UserDefaults.standard.set(finalRecords.count, forKey: "isoWalkBadgesEarnedTotal")

        if let firstNew = newlyEarnedInThisSession.first,
           let matchedBadge = badges.first(where: { $0.id.rawValue == firstNew.badgeId }) {
            
            UserDefaults.standard.set(matchedBadge.id.rawValue, forKey: "mostRecentBadgeId")
            newlyUnlockedBadge = matchedBadge
            showRevealAnimation = true
        }
    }
}

