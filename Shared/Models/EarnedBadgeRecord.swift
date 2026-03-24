//
//  EarnedBadgeRecord.swift
//  isoWalk
//
//  Created by AnnElaine on 3/23/26.
//

import Foundation
import SwiftData

@Model
final class EarnedBadgeRecord {
    var id: UUID
    var badgeId: String
    var earnedDate: Date
    
    init(id: UUID = UUID(), badgeId: String, earnedDate: Date) {
        self.id = id
        self.badgeId = badgeId
        self.earnedDate = earnedDate
    }
}

