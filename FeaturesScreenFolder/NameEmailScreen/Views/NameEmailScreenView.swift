//
//  NameEmailScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//
//  PARENT VIEW — intentionally dumb.
//  Owns NameEmailViewModel. Passes data and callbacks to child components.
//  Pushed via NavigationStack from FeaturesHomeScreenView.
//  Keyboard slides OVER the BottomNavBar — never pushes content up.
//  Dragging down on scroll OR tapping background dismisses keyboard.
//  Color.clear overlay removed — was blocking text field taps.
//

import SwiftUI

struct NameEmailScreenView: View {

    @State private var viewModel = NameEmailViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(IsoWalkThemes.selectedThemeKey) private var selectedThemeId: String = IsoWalkThemes.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkThemes.current(selectedId: selectedThemeId) }

    private let navBarHeight: CGFloat = 115
    private let maxCardWidth: CGFloat = 340

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                themeBackground

                VStack(spacing: 0) {

                    // MARK: - Back button row
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(isoWalkColors.deepSpaceBlue)
                                .padding(12)
                        }
                        .padding(.leading, 32)
                        Spacer()
                    }
                    .padding(.top, -8)

                    // MARK: - Scrollable content
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {

                                // Hero theme image
                                ThemeHeaderPreview(
                                    theme: theme,
                                    frameSize: 160
                                )
                                .padding(.top, 8)
                                .padding(.bottom, 16)

                                // Title
                                HStack {
                                    Text("Name & Email")
                                        .font(.custom("Inter-Bold", size: 34))
                                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                                    Spacer()
                                }
                                .padding(.horizontal, max((geo.size.width - maxCardWidth) / 2, 20))
                                .padding(.bottom, 28)

                                // MARK: - Name Field
                                NameInputField(
                                    name: $viewModel.name,
                                    maxLength: viewModel.maxNameLength,
                                    onEndEditing: { viewModel.nameFieldDidEndEditing() }
                                )
                                .padding(.horizontal, max((geo.size.width - maxCardWidth) / 2, 20))
                                .padding(.bottom, 24)
                                .id("nameField")

                                // MARK: - Email Field
                                EmailInputField(
                                    email: $viewModel.email,
                                    errorMessage: viewModel.emailError,
                                    isSaved: viewModel.emailSaved,
                                    onSave: {
                                        viewModel.saveEmail()
                                        hideKeyboard()
                                    }
                                )
                                .padding(.horizontal, max((geo.size.width - maxCardWidth) / 2, 20))
                                .padding(.bottom, 40)
                                .id("emailField")
                                .onTapGesture {
                                    withAnimation {
                                        proxy.scrollTo("emailField", anchor: .center)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            // Tapping the background (not a field) dismisses keyboard
                            .background(
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture { hideKeyboard() }
                            )
                        }
                        // Dragging scroll view down dismisses keyboard naturally
                        .scrollDismissesKeyboard(.interactively)
                    }
                }
                .frame(width: geo.size.width, height: max(0, geo.size.height - navBarHeight))
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
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
        NameEmailScreenView()
    }
}
