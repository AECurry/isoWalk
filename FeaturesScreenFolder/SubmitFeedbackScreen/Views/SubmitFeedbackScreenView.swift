//
//  SubmitFeedbackScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns SubmitFeedbackViewModel and assembles child components.
//

import SwiftUI

struct SubmitFeedbackScreenView: View {

    @State private var viewModel = SubmitFeedbackViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }
    @FocusState private var focusedField: FeedbackField?

    private let navBarHeight: CGFloat = 115
    private let maxContentWidth: CGFloat = 340

    enum FeedbackField { case name, email, message }

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
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {

                                HStack {
                                    Text("Submit Feedback")
                                        .font(.custom("Inter-Bold", size: 34))
                                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                                    Spacer()
                                }
                                .padding(.horizontal, max((geo.size.width - maxContentWidth) / 2, 20))
                                .padding(.top, 16) // Compensates for removed image padding
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
                            .background(
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture { hideKeyboard() }
                            )
                        }
                        .scrollDismissesKeyboard(.interactively)
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

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
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

