//
//  NotificationsScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns NotificationsViewModel. Passes data and callbacks to child components.
//  - FIXED: Image Area extracted to stay fixed while content below scrolls naturally.
//

import SwiftUI

struct NotificationsScreenView: View {

    @State private var viewModel = NotificationsViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    private let navBarHeight: CGFloat = 115

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                
                // LAYER 1: Floating Navigation
                IsoWalkBackButton(theme: theme, onBack: { dismiss() })
                    .zIndex(10)

                // LAYER 2: Main Content
                VStack(spacing: 0) {
                    
                    // MARK: - Shared Theme Image Area (Fixed)
                    isoWalkThemeImageArea(theme: theme, isAnimated: true)
                        .frame(maxWidth: .infinity)

                    // MARK: - Scrollable Content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {

                            HStack {
                                Text("Notifications")
                                    .font(.custom("Inter-Bold", size: 34))
                                    .foregroundColor(isoWalkColors.deepSpaceBlue)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16) // Compensates for removed image padding
                            .padding(.bottom, 24)

                            // MARK: - 6 Toggle Cards
                            VStack(spacing: 12) {

                                NotificationToggleRow(
                                    icon: "bell.fill",
                                    title: "Daily Walking Reminder",
                                    subtitle: "A gentle nudge at 9 AM every day to take your walk",
                                    isOn: $viewModel.isDailyReminderOn
                                )

                                NotificationToggleRow(
                                    icon: "flame.fill",
                                    title: "Streak Alert",
                                    subtitle: "Warned before you lose your daily walking streak",
                                    isOn: $viewModel.isStreakAlertOn
                                )

                                NotificationToggleRow(
                                    icon: "medal.fill",
                                    title: "Badge Earned",
                                    subtitle: "Celebrated the moment you unlock a new badge",
                                    isOn: $viewModel.isBadgeEarnedOn
                                )

                                NotificationToggleRow(
                                    icon: "figure.walk.circle.fill",
                                    title: "Walk Complete Summary",
                                    subtitle: "A recap delivered right after each walk you finish",
                                    isOn: $viewModel.isWalkSummaryOn
                                )

                                NotificationToggleRow(
                                    icon: "chart.bar.fill",
                                    title: "Weekly Progress Report",
                                    subtitle: "Your walk count for the week, every Sunday evening",
                                    isOn: $viewModel.isWeeklyReportOn
                                )

                                NotificationToggleRow(
                                    icon: "heart.fill",
                                    title: "Inactivity Nudge",
                                    subtitle: "A caring check-in if you haven't walked in 2 days",
                                    isOn: $viewModel.isInactivityNudgeOn
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: geo.size.width, height: max(0, geo.size.height - navBarHeight))
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .background {
            themeBackground
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .alert("Notifications Turned Off", isPresented: $viewModel.showDeniedAlert) {
            Button("Open Settings") { viewModel.openSettings() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("isoWalk needs permission to send you notifications. Please enable them in Settings.")
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
    NavigationStack {
        NotificationsScreenView()
    }
}

