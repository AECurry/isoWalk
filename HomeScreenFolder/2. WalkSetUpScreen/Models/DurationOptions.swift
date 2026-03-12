//
//  DurationOptions.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//

import Foundation

enum DurationOptions: String, CaseIterable, Identifiable, Codable {
    case fifteen = "15 min"
    case twenty = "20 min"
    case thirty = "30 min"
    case fortyFive = "45 min"
    case sixty = "60 min"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
    var minutes: Int {
        switch self {
        case .fifteen: return 15
        case .twenty: return 20
        case .thirty: return 30
        case .fortyFive: return 45
        case .sixty: return 60
        }
    }
    
    // Returns cycle breakdown for a given pace
    func cycleInfo(for pace: PaceOptions) -> CycleInfo {
        switch pace {
        case .leisurely: return cycleInfo3to1
        case .steady: return cycleInfo3to2
        case .brisk: return cycleInfo3to3
        }
    }
    
    // MARK: - 3:1 Pace (3 min Normal, 1 min Brisk)
    private var cycleInfo3to1: CycleInfo {
        switch self {
        case .fifteen:
            // N-B-N-B-N-B-N = 3+1+3+1+3+1+3 = 15 min
            return CycleInfo(
                totalCycles: 7,
                normalCount: 4,
                briskCount: 3,
                normalDuration: 3,
                briskDuration: 1,
                finalNormalDuration: 3,
                cooldownExtension: 0
            )
        case .twenty:
            // 3+1+3+1+3+1+3+1+3 = 18 min, final N = 5 min → 20 min
            return CycleInfo(
                totalCycles: 9,
                normalCount: 5,
                briskCount: 4,
                normalDuration: 3,
                briskDuration: 1,
                finalNormalDuration: 5,
                cooldownExtension: 2
            )
        case .thirty:
            // 3+1+3+1+3+1+3+1+3+1+3+1+3+1+3 = 28 min, final N = 5 min → 30 min
            return CycleInfo(
                totalCycles: 15,
                normalCount: 8,
                briskCount: 7,
                normalDuration: 3,
                briskDuration: 1,
                finalNormalDuration: 5,
                cooldownExtension: 2
            )
        case .fortyFive:
            // 3+1+3+1+3+1+3+1+3+1+3+1+3+1+3+1+3+1+3+1+3 = 43 min, final N = 5 min → 45 min
            return CycleInfo(
                totalCycles: 21,
                normalCount: 11,
                briskCount: 10,
                normalDuration: 3,
                briskDuration: 1,
                finalNormalDuration: 5,
                cooldownExtension: 2
            )
        case .sixty:
            // 3+1+3+1+3+1+3+1+3+1+3+1+3+1+3+1+3+1+3+1+3+1+3+1+3+1+3+1+3 = 59 min, final N = 4 min → 60 min
            return CycleInfo(
                totalCycles: 29,
                normalCount: 15,
                briskCount: 14,
                normalDuration: 3,
                briskDuration: 1,
                finalNormalDuration: 4,
                cooldownExtension: 1
            )
        }
    }
    
    // MARK: - 3:2 Pace (3 min Normal, 2 min Brisk)
    private var cycleInfo3to2: CycleInfo {
        switch self {
        case .fifteen:
            // N-B-N-B-N = 3+2+3+2+3 = 13 min, final N = 5 min → 15 min
            return CycleInfo(
                totalCycles: 5,
                normalCount: 3,
                briskCount: 2,
                normalDuration: 3,
                briskDuration: 2,
                finalNormalDuration: 5,
                cooldownExtension: 2
            )
        case .twenty:
            // 3+2+3+2+3+2+3 = 18 min, final N = 5 min → 20 min
            return CycleInfo(
                totalCycles: 7,
                normalCount: 4,
                briskCount: 3,
                normalDuration: 3,
                briskDuration: 2,
                finalNormalDuration: 5,
                cooldownExtension: 2
            )
        case .thirty:
            // 3+2+3+2+3+2+3+2+3+2+3 = 28 min, final N = 5 min → 30 min
            return CycleInfo(
                totalCycles: 11,
                normalCount: 6,
                briskCount: 5,
                normalDuration: 3,
                briskDuration: 2,
                finalNormalDuration: 5,
                cooldownExtension: 2
            )
        case .fortyFive:
            // 3+2+3+2+3+2+3+2+3+2+3+2+3+2+3+2+3 = 43 min, final N = 5 min → 45 min
            return CycleInfo(
                totalCycles: 17,
                normalCount: 9,
                briskCount: 8,
                normalDuration: 3,
                briskDuration: 2,
                finalNormalDuration: 5,
                cooldownExtension: 2
            )
        case .sixty:
            // 3+2+3+2+3+2+3+2+3+2+3+2+3+2+3+2+3+2+3+2+3+2+3 = 58 min, final N = 5 min → 60 min
            return CycleInfo(
                totalCycles: 23,
                normalCount: 12,
                briskCount: 11,
                normalDuration: 3,
                briskDuration: 2,
                finalNormalDuration: 5,
                cooldownExtension: 2
            )
        }
    }
    
    // MARK: - 3:3 Pace (3 min Normal, 3 min Brisk) — Dr. Masuki's Protocol
    private var cycleInfo3to3: CycleInfo {
        switch self {
        case .fifteen:
            // N-B-N-B-N = 3+3+3+3+3 = 15 min exactly
            return CycleInfo(
                totalCycles: 5,
                normalCount: 3,
                briskCount: 2,
                normalDuration: 3,
                briskDuration: 3,
                finalNormalDuration: 3,
                cooldownExtension: 0
            )
        case .twenty:
            // 3+3+3+3+3+3 = 18 min, final N = 5 min → 20 min
            return CycleInfo(
                totalCycles: 7,
                normalCount: 4,
                briskCount: 3,
                normalDuration: 3,
                briskDuration: 3,
                finalNormalDuration: 5,
                cooldownExtension: 2
            )
        case .thirty:
            // 3+3+3+3+3+3+3+3+3 = 27 min, final N = 6 min → 30 min
            return CycleInfo(
                totalCycles: 10,
                normalCount: 5,
                briskCount: 4,
                normalDuration: 3,
                briskDuration: 3,
                finalNormalDuration: 6,
                cooldownExtension: 3
            )
        case .fortyFive:
            // 3+3+3+3+3+3+3+3+3+3+3+3+3+3+3 = 45 min exactly
            return CycleInfo(
                totalCycles: 15,
                normalCount: 8,
                briskCount: 7,
                normalDuration: 3,
                briskDuration: 3,
                finalNormalDuration: 3,
                cooldownExtension: 0
            )
        case .sixty:
            // 3+3+3+3+3+3+3+3+3+3+3+3+3+3+3+3+3+3+3 = 57 min, final N = 6 min → 60 min
            return CycleInfo(
                totalCycles: 20,
                normalCount: 10,
                briskCount: 9,
                normalDuration: 3,
                briskDuration: 3,
                finalNormalDuration: 6,
                cooldownExtension: 3
            )
        }
    }
    
    // Dynamic description based on pace
    func description(for pace: PaceOptions) -> String {
        let info = cycleInfo(for: pace)
        return "\(info.totalCycles) cycles · \(minutes) min walk"
    }
    
    // Recommended duration (30 min aligns with Dr. Masuki's research)
    static let recommended: DurationOptions = .thirty
}

// MARK: - Cycle Info Model
struct CycleInfo {
    let totalCycles: Int              // Total number of intervals (N + B combined)
    let normalCount: Int              // Number of Normal intervals
    let briskCount: Int               // Number of Brisk intervals
    let normalDuration: Int           // Standard Normal interval length (minutes)
    let briskDuration: Int            // Standard Brisk interval length (minutes)
    let finalNormalDuration: Int      // Final Normal interval length (may be extended)
    let cooldownExtension: Int        // Extra minutes added to final Normal interval
    
    var intervalSequence: [WalkInterval] {
        var sequence: [WalkInterval] = []
        
        // Add alternating N-B pairs (all except the last Normal)
        for _ in 0..<briskCount {
            sequence.append(WalkInterval(pace: .normal, duration: normalDuration))
            sequence.append(WalkInterval(pace: .brisk, duration: briskDuration))
        }
        
        // Add final Normal interval (potentially extended for cool-down)
        sequence.append(WalkInterval(pace: .normal, duration: finalNormalDuration))
        
        return sequence
    }
}

// MARK: - Walk Interval Model
struct WalkInterval: Identifiable {
    let id = UUID()
    let pace: WalkPaceTag
    let duration: Int  // in minutes
}

