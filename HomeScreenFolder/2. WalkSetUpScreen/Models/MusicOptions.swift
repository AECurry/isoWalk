//
//  MusicOption.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import Foundation

// This is the definition the other file is looking for!
enum MusicOptions: String, CaseIterable, Identifiable, Codable {
    case placeholder
    case zenGarden
    case upbeatMix
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .placeholder: return "No Music"
        case .zenGarden: return "Zen Garden"
        case .upbeatMix: return "Upbeat Mix"
        }
    }
}

