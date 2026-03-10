//
//  FeedbackFormCard.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//
//  CHILD COMPONENT — the form card only.
//  Owns: To (read-only), Name, Email, Message fields.
//  Keyboard toolbar with ▼ dismiss arrow on every field.
//  Parent passes viewModel and focusedField binding in.
//

import SwiftUI

struct FeedbackFormCard: View {

    @Bindable var viewModel: SubmitFeedbackViewModel
    @FocusState.Binding var focusedField: SubmitFeedbackScreenView.FeedbackField?
    let scrollProxy: ScrollViewProxy

    var body: some View {
        VStack(spacing: 20) {

            // MARK: - To (read-only)
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(isoWalkColors.balticBlue)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 3) {
                    Text("To")
                        .font(.custom("Inter-SemiBold", size: 14))
                        .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.55))
                    Text(viewModel.companyEmail)
                        .font(.custom("Inter-Regular", size: 15))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }

            Divider()

            // MARK: - Name
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(isoWalkColors.balticBlue)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Your Name")
                        .font(.custom("Inter-SemiBold", size: 14))
                        .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.55))
                    TextField("Optional", text: $viewModel.name)
                        .font(.custom("Inter-Regular", size: 15))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button(action: { focusedField = nil }) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(isoWalkColors.balticBlue)
                                }
                            }
                        }
                }
                Spacer()
            }

            Divider()

            // MARK: - Email
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "at")
                        .font(.system(size: 16))
                        .foregroundStyle(isoWalkColors.balticBlue)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Your Email")
                            .font(.custom("Inter-SemiBold", size: 14))
                            .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.55))
                        TextField("So we can reply to you", text: Binding(
                            get: { viewModel.email },
                            set: { viewModel.email = $0; viewModel.emailDidChange() }
                        ))
                        .font(.custom("Inter-Regular", size: 15))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .message }
                    }
                    Spacer()
                }
                if let error = viewModel.emailError {
                    Text(error)
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.leading, 36)
                }
            }

            Divider()

            // MARK: - Message
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 16))
                        .foregroundStyle(isoWalkColors.balticBlue)
                        .frame(width: 24)
                    Text("Message")
                        .font(.custom("Inter-SemiBold", size: 14))
                        .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.55))
                    Spacer()
                }

                ZStack(alignment: .topLeading) {
                    if viewModel.message.isEmpty {
                        Text("Write your message here…")
                            .font(.custom("Inter-Regular", size: 15))
                            .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.30))
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $viewModel.message)
                        .font(.custom("Inter-Regular", size: 15))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($focusedField, equals: .message)
                        .onChange(of: focusedField) { _, newValue in
                            if newValue == .message {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    withAnimation {
                                        scrollProxy.scrollTo("sendButton", anchor: .bottom)
                                    }
                                }
                            }
                        }
                }
                .padding(.leading, 36)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isoWalkColors.ivory)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
    }
}

