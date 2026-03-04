//
//  DurationOption.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import Foundation

enum DurationOptions: String, CaseIterable, Identifiable, Codable {
    case fifteen = "15 min"
    case twentyOne = "21 min"
    case twentySeven = "27 min"
    case thirtyThree = "33 min"
    case fortyFive = "45 min"
    case sixty = "60 min"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
    var minutes: Int {
        switch self {
        case .fifteen: return 15
        case .twentyOne: return 21
        case .twentySeven: return 27
        case .thirtyThree: return 33
        case .fortyFive: return 45
        case .sixty: return 60
        }
    }
    
    var description: String {
        switch self {
        case .fifteen: return "Short walk (5 cycles)"
        case .twentyOne: return "Post-meal walk (7 cycles)"
        case .twentySeven: return "Standard session (9 cycles)"
        case .thirtyThree: return "Extended session (11 cycles)"
        case .fortyFive: return "Long session (15 cycles)"
        case .sixty: return "Maximum session (20 cycles)"
        }
    }
    
    // 21 min is recommended for post-meal walking
    static let recommended: DurationOptions = .twentyOne
}

