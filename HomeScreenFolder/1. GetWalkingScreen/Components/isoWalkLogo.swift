//
//  IsoWalkLogoView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI

struct IsoWalkLogoView: View {
    var body: some View {
        Image("isoWalkLogo")
            .resizable()
            .scaledToFit()
            .frame(height: 50)
            .padding(.vertical, 16)
    }
}

