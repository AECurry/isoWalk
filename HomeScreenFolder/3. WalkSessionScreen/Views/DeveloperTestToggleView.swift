//
//  DeveloperTestToggleView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI

struct DeveloperTestToggleView: View {
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Developer Testing")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            Toggle("Developer Testing", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .red))
        }
        .padding()
    }
}

