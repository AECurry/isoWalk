//
//  isoWalkMainView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  ROOT VIEW — intentionally dumb.
//  Owns tab state, the fullScreenCover, and the single BottomNavBar instance.
//  Has zero knowledge of walk sessions, alerts, or what any tab contains.
//

import SwiftUI

struct isoWalkMainView: View {
    @State private var selectedTab: Int = 0
    @State private var showingSetup: Bool = false
    @Environment(SessionManager.self) private var sessionManager

    var body: some View {
        ZStack(alignment: .bottom) {

            // MARK: - Tab Content
            TabView(selection: Binding(
                get: { selectedTab },
                set: { newTab in
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        selectedTab = newTab
                    }
                }
            )) {
                GetWalkingView(onStartWalking: { showingSetup = true })
                    .tag(0)
                ProgressScreenView()
                    .tag(1)
                Text("Features Screen")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // MARK: - Nav Bar
            BottomNavBar(
                selectedTab: $selectedTab,
                onTabReTap: { showingSetup = true }
            )
        }
        // MARK: - fullScreenCover
        // WalkSetUpView owns its NavigationStack and pushes WalkSessionView.
        // This view only knows the cover exists — nothing about what is inside.
        .fullScreenCover(isPresented: $showingSetup) {
            WalkSetUpView(
                selectedTab: $selectedTab,
                onDismiss: { showingSetup = false }
            )
        }
    }
}

#Preview {
    isoWalkMainView()
        .environment(SessionManager())
}
