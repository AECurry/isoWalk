//
//  NameInputField.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//
//  COMPONENT — dumb child.
//  Name text field with label and character count.
//  Hard stops at 9 characters — enforced by ViewModel.
//  Receives all state and callbacks from parent — owns nothing.
//

import SwiftUI

struct NameInputField: View {

    @Binding var name: String
    let maxLength: Int
    let onEndEditing: () -> Void

    private let fieldCornerRadius: CGFloat = 12
    private let labelFontSize: CGFloat = 16
    private let inputFontSize: CGFloat = 17

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Label row with character count
            HStack {
                Text("Name")
                    .font(.custom("Inter-SemiBold", size: labelFontSize))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)

                Spacer()

                Text("\(name.count)/\(maxLength)")
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundColor(
                        name.count >= maxLength
                        ? isoWalkColors.forestGreen
                        : isoWalkColors.deepSpaceBlue.opacity(0.4)
                    )
            }

            // Text field
            TextField("", text: $name)
                .font(.custom("Inter-Regular", size: inputFontSize))
                .foregroundColor(isoWalkColors.deepSpaceBlue)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: fieldCornerRadius)
                        .fill(isoWalkColors.deepSpaceBlue.opacity(0.06))
                )
                .submitLabel(.done)
                .onSubmit { onEndEditing() }
        }
    }
}

#Preview {
    NameInputField(
        name: .constant("Friend"),
        maxLength: 9,
        onEndEditing: {}
    )
    .padding()
    .background(isoWalkColors.parchment)
}
