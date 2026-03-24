//
//  AppleMusicService.swift
//  isoWalk
//
//  Created by AnnElaine on 3/23/26.
//
//
//  Handles MusicKit authorization and Apple Music catalog searches.
//

import Foundation
import MusicKit
import StoreKit
import Observation

@Observable
final class AppleMusicService {
    
    // MARK: - Singleton
    static let shared = AppleMusicService()
    
    // MARK: - State
    var isAuthorized: Bool = false
    var authorizationStatus: MusicAuthorization.Status = .notDetermined
    
    private init() {
        self.authorizationStatus = MusicAuthorization.currentStatus
        self.isAuthorized = (self.authorizationStatus == .authorized)
    }
    
    // MARK: - Authorization
    
    /// Requests access to the user's Apple Music account.
    func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        
        // Update state on the main thread so the UI can react
        await MainActor.run {
            self.authorizationStatus = status
            self.isAuthorized = (status == .authorized)
            
            if status == .authorized {
                print("✅ Apple Music authorization granted.")
            } else {
                print("❌ Apple Music authorization denied or restricted.")
            }
        }
    }
    
    // MARK: - Catalog Search
    
    /// Searches the Apple Music catalog for a given text string.
    func searchSongs(query: String) async throws -> [Song] {
        guard isAuthorized else {
            print("⚠️ Cannot search: Apple Music not authorized.")
            return []
        }
        
        var request = MusicCatalogSearchRequest(term: query, types: [Song.self])
        request.limit = 15 // Fetch top 15 results
        
        let response = try await request.response()
        return Array(response.songs)
    }
}

