//
//  TimePickerRow.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//
//  COMPONENT — dumb child.
//  Animated time picker card that slides in when Daily Reminder is toggled on.
//  Receives all state and callbacks from parent — owns nothing.
//

import SwiftUI

struct TimePickerRow: View {

    @Binding var reminderTime: Date
    let isVisible: Bool

    var body: some View {
        if isVisible {
            VStack(spacing: 0) {
                Divider()
                    .padding(.horizontal, 20)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reminder Time")
                            .font(.custom("Inter-SemiBold", size: 15))
                            .foregroundStyle(isoWalkColors.deepSpaceBlue)
                        Text("Choose when you want your daily nudge")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundStyle(isoWalkColors.deepSpaceBlue.opacity(0.55))
                    }
                    Spacer()
                    DatePicker(
                        "",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .colorScheme(.light)
                    .accentColor(isoWalkColors.balticBlue)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isoWalkColors.ivory.opacity(0.85))
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                )
            }
            .transition(.asymmetric(
                insertion: .push(from: .top).combined(with: .opacity),
                removal: .push(from: .bottom).combined(with: .opacity)
            ))
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        TimePickerRow(reminderTime: .constant(Date()), isVisible: true)
    }
    .padding()
    .background(isoWalkColors.parchment)
}
