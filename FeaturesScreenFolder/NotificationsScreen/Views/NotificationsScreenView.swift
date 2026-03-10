//
//  NotificationsScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns NotificationsViewModel. Passes data and callbacks to child components.
//  ScrollView starts from top of screen (ignoresSafeArea).
//  Back button floats over content in ZStack — same structure as ThemeOptionsView.
//  Denied alert mirrors HealthKit pattern with Open Settings button.
//

import SwiftUI

struct NotificationsScreenView: View {

    @State private var viewModel = NotificationsViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(IsoWalkThemes.selectedThemeKey) private var selectedThemeId: String = IsoWalkThemes.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkThemes.current(selectedId: selectedThemeId) }

    private let navBarHeight: CGFloat = 115

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                themeBackground

                // MARK: - Scrollable Content (starts from very top)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {

                        ThemeHeaderPreview(
                            theme: theme,
                            frameSize: 200
                        )
                        .padding(.top, 56)
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity)

                        HStack {
                            Text("Notifications")
                                .font(.custom("Inter-Bold", size: 34))
                                .foregroundColor(isoWalkColors.deepSpaceBlue)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
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
                .ignoresSafeArea(edges: .top)
                .frame(width: geo.size.width, height: max(0, geo.size.height - navBarHeight))

                // MARK: - Back Button (floats over scroll content)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(isoWalkColors.deepSpaceBlue)
                            .padding(12)
                    }
                    .padding(.leading, 56)
                    Spacer()
                }
                .padding(.top, -8)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
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

