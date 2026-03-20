//
//  NameEmailScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns NameEmailViewModel. Passes data and callbacks to child components.
//  ScrollView starts from top of screen (ignoresSafeArea).
//  Back button floats over content in ZStack — same structure as ThemeOptionsView.
//  Keyboard slides OVER the BottomNavBar — never pushes content up.
//

import SwiftUI

struct NameEmailScreenView: View {

    @State private var viewModel = NameEmailViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    private let navBarHeight: CGFloat = 115
    private let maxCardWidth: CGFloat = 340

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                themeBackground

                // MARK: - Scrollable Content (starts from very top)
                ScrollViewReader { proxy in
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
                        .background(
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture { hideKeyboard() }
                        )
                    }
                    .ignoresSafeArea(edges: .top)
                    .scrollDismissesKeyboard(.interactively)
                    .frame(width: geo.size.width, height: max(0, geo.size.height - navBarHeight))
                }

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

