//
//  isoWalkApp.swift
//  isoWalk
//
//  Created by AnnElaine on 2/12/26.
//
//  APP ROOT — creates shared services and injects them into the environment.
//  No business logic lives here. Both coordinators are created once and live
//  for the entire app lifetime.
//

import SwiftUI

@main
struct isoWalkApp: App {
    @State private var sessionManager = SessionManager()
    

    var body: some Scene {
        WindowGroup {
            isoWalkMainView()
                .environment(sessionManager)
                
        }
    }
}
