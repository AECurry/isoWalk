//
//  NameEmailScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns NameEmailViewModel. Passes data and callbacks to child components.
//  - FIXED: Image Area extracted to stay fixed while content below scrolls naturally.
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
                                    Text("Name & Email")
                                        .font(.custom("Inter-Bold", size: 34))
                                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                                    Spacer()
                                }
                                .padding(.horizontal, max((geo.size.width - maxCardWidth) / 2, 20))
                                .padding(.top, 16) // Compensates for removed image padding
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

