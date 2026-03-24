//
//  SubmitFeedbackScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns SubmitFeedbackViewModel and assembles child components.
//  ScrollView starts from top of screen (ignoresSafeArea).
//

import SwiftUI

struct SubmitFeedbackScreenView: View {

    @State private var viewModel = SubmitFeedbackViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }
    @FocusState private var focusedField: FeedbackField?

    // Removed navBarHeight as we're letting the ScrollView size itself naturally
    private let maxContentWidth: CGFloat = 340

    enum FeedbackField { case name, email, message }

    var body: some View {
        // Outer ZStack keeps the background isolated from the GeometryReader's resizing
        // when the keyboard appears
        ZStack(alignment: .top) {
            themeBackground

            GeometryReader { geo in
                ZStack(alignment: .top) {
                    
                    // MARK: - Scrollable Content
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {

                                // MARK: - Shared Theme Image Area
                                isoWalkThemeImageArea(theme: theme, isAnimated: true)
                                    .padding(.top, 56)
                                    .padding(.bottom, 16)
                                    .frame(maxWidth: .infinity)

                                HStack {
                                    Text("Submit Feedback")
                                        .font(.custom("Inter-Bold", size: 34))
                                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                                    Spacer()
                                }
                                .padding(.horizontal, max((geo.size.width - maxContentWidth) / 2, 20))
                                .padding(.bottom, 8)

                                HStack {
                                    Text("Your feedback helps us make isoWalk better for everyone.")
                                        .font(.custom("Inter-Regular", size: 15))
                                        .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.70))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
                                .padding(.horizontal, max((geo.size.width - maxContentWidth) / 2, 20))
                                .padding(.bottom, 28)

                                // MARK: - Form Card (child)
                                FeedbackFormCard(
                                    viewModel: viewModel,
                                    focusedField: $focusedField,
                                    scrollProxy: proxy
                                )
                                .padding(.horizontal, max((geo.size.width - maxContentWidth) / 2, 20))
                                .padding(.bottom, 20)

                                // MARK: - Send Button (child)
                                FeedbackSendButton {
                                    focusedField = nil
                                    viewModel.submit()
                                }
                                .padding(.horizontal, max((geo.size.width - maxContentWidth) / 2, 20))
                                .padding(.bottom, 40)
                                .id("sendButton")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .ignoresSafeArea(edges: .top)
                        .scrollDismissesKeyboard(.interactively)
                        // Removed the restrictive .frame(height: ...) here to allow dynamic resizing
                    }

                    // MARK: - Back Button (floats over scroll content)
                    IsoWalkBackButton(theme: theme, onBack: { dismiss() })
                }
            }
        }
        .navigationBarHidden(true)
        // Removed .ignoresSafeArea(.keyboard) so the view shrinks and scrolls when the keyboard opens

        .alert("No Email App Found", isPresented: $viewModel.showNoEmailAppAlert) {
            Button("Copy Email Address") {
                UIPasteboard.general.string = viewModel.companyEmail
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("No email app was found on this device. You can copy our email address and reach us from any browser or device.")
        }

        .alert("Message Required", isPresented: $viewModel.showEmptyMessageAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please write a message before sending.")
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
        SubmitFeedbackScreenView()
    }
}

