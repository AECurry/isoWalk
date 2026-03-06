//
//  ProgressScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  LOCATION: ProgressScreenFolder/Views/
//
//  PARENT VIEW — intentionally dumb.
//  Owns ProgressViewModel. Passes data down to child components.
//


import SwiftUI

struct ProgressScreenView: View {

    @State private var viewModel = ProgressViewModel()
    @AppStorage("userName") private var userName: String = ""
    @AppStorage(IsoWalkThemes.selectedThemeKey) private var selectedThemeId: String = IsoWalkThemes.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkThemes.current(selectedId: selectedThemeId) }

    // BottomNavBar (~83pt) + 32pt gap above it
    private let navBarHeight: CGFloat = 115

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                themeBackground

                VStack(spacing: 0) {

                    // MARK: - FIXED: Header
                    ProgressHeader(
                        userName: userName,
                        totalWalkCount: viewModel.totalWalkCountDisplay,
                        mostRecentBadgeId: viewModel.mostRecentBadgeId
                    )

                    // MARK: - FIXED: Total counter
                    ProgressTotalCounter(
                        formattedTotalTime: viewModel.formattedTotalTime,
                        isHealthKitEnabled: viewModel.isHealthKitEnabled
                    )

                    // MARK: - FIXED: Today label
                    HStack {
                        Text("Today")
                            .font(.custom("Inter-Bold", size: 22))
                            .foregroundColor(isoWalkColors.deepSpaceBlue)
                            .padding(.leading, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 4)
                        Spacer()
                    }

                    // MARK: - SCROLLABLE: Cards
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            TodayTimelineCard(sessions: viewModel.timelineSessions)
                            TodayStatsCard(
                                formattedActiveTime: viewModel.formattedTodayTime,
                                sessionCount: viewModel.todaySessionCount,
                                isHealthKitEnabled: viewModel.isHealthKitEnabled,
                                miles: 0
                            )
                            StreakCard(
                                walksThisMonth: viewModel.walksThisMonth,
                                longestStreak: viewModel.longestStreak
                            )
                            BadgesCard(badgesEarned: viewModel.badgesEarned)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                        .padding(.bottom, 16)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height - navBarHeight)
            }
            // This is the centering fix — fills full width and height
            // so GeometryReader does not default to top-left alignment
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .onAppear {
            viewModel.loadData()
        }
    }

    @ViewBuilder
    private var themeBackground: some View {
        if let bgName = theme.backgroundImageName {
            Image(bgName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        } else {
            theme.backgroundColor.ignoresSafeArea()
        }
    }
}

#Preview {
    ProgressScreenView()
        .environment(SessionManager())
}

