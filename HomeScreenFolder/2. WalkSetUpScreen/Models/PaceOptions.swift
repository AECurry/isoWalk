//
//  PaceOptions.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import Foundation

enum PaceOptions: String, CaseIterable, Identifiable, Codable {
    case leisurely = "3 min to 1 min pace"
    case steady = "3 min to 2 min pace"
    case brisk = "3 min to 3 min pace"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
    var description: String {
        switch self {
        case .leisurely: return "A relaxed pace for those just getting started."
        case .steady: return "A consistent pace for those ready to up their game."
        case .brisk: return "The perfect pace to receive all the benefits of isoWalk."
        }
    }
}

