//
//  ProgressHeader.swift
//  isoWalk
//
//  Created by AnnElaine on 2/26/26.
//

import SwiftUI

struct ProgressHeader: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("totalWalkCount") private var totalWalkCount: Int = 0
    
    var body: some View {
        // 1. Set a consistent spacing here (e.g., 20)
        HStack(alignment: .center, spacing: 24) {
            
            // LEFT: Greeting
            VStack(spacing: 8) {
                Image("HandWavingIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                VStack(spacing: 4) {
                    Text("Hello")
                    Text(userName.isEmpty ? "Friend" : userName)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(isoWalkColors.deepSpaceBlue)
            }
            .frame(width: 96)
            
            
            // CENTER: Badge Display
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 152, height: 152)
                
                Image(systemName: "photo")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            // RIGHT: Total Walks
            VStack(spacing: 8) {
                Image("CalendarIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                VStack(spacing: 4) {
                    Text("\(totalWalkCount)")
                        .font(.custom("Inter-Bold", size: 24))
                    
                    Text("Total Walks")
                        .fixedSize(horizontal: true, vertical: false)
                }
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(isoWalkColors.deepSpaceBlue)
            }
            .frame(width: 96)
            
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}
#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        ProgressHeader()
    }
}

